require "json"
require "play_by_play/model/game_play"
require "play_by_play/model/invalid_state_error"
require "play_by_play/model/play"
require "play_by_play/model/possession"
require "play_by_play/persistent/game"
require "play_by_play/persistent/play"
require "play_by_play/persistent/possession"
require "play_by_play/repository"
require "play_by_play/sample/row"

module PlayByPlay
  module Sample
    module Game
      def self.new_game(nba_id, visitor_abbreviation, home_abbreviation)
        Persistent::Game.new(
          home: Persistent::Team.new(abbreviation: home_abbreviation),
          nba_id: nba_id,
          visitor: Persistent::Team.new(abbreviation: visitor_abbreviation)
        )
      end

      def self.import(game, path, repository: Repository.new, invalid_state_error: true)
        return false if repository.games.exists?(game.nba_id)

        # All-Star Game
        return false if game.nba_id == "0031400001"

        json = read_json(path, game.nba_id)
        game = parse(game, json, invalid_state_error)
        game
      end

      def self.read_json(path, nba_id)
        JSON.parse(File.read("#{path}/#{nba_id}.json"))
      end

      def self.parse(game, json, invalid_state_error = true)
        add_rows(game, json, json["resultSets"].first["headers"])

        game.rows.each do |row|
          debug(game.possession, row)
          next if ignore?(game.possession, row)

          begin
            row.possession = game.possession
            row = correct_row(row)

            play = play!(game, row.play_type, row.play_attributes)
            play.row = row

            validate_score! game.possession, row
            break if game.possession.errors?
          rescue Model::InvalidStateError, ArgumentError => e
            raise e if invalid_state_error
            game.error_eventnum = row.eventnum
            game.errors << e.message
            break
          end
        end

        PlayByPlay.logger.info(sample_game: :parse, nba_id: game.nba_id, errors: game.errors)

        game
      end

      def self.play!(game, play_type, play_attributes = {})
        play = Model::Play.new(play_type, play_attributes)
        possession = Model::GamePlay.play!(game.possession, play)
        debug_play possession, play

        play = Persistent::Play.new(play_type, play_attributes.merge(possession: game.possession))
        game.possession.play = play

        possession = Persistent::Possession.new(possession.attributes)
        game.possessions << possession
        play
      end

      # Map JSON array to Sample::Row
      def self.add_rows(game, json, headers)
        json["resultSets"].first["rowSet"].map do |json_row|
          Row.new(game, headers, json_row)
        end
      end

      # Source data may have specific problems
      # Change to correct_play
      def self.correct_row(row)
        if row.misidentified_shooting_foul?
          row.eventmsgactiontype = 2
        end

        if row.game.nba_id == "0021400009" && row.eventnum == 393
          row.eventmsgactiontype = 7
        end

        row
      end

      def self.ignore?(possession, row)
        row.uncounted_team_rebound?(possession) ||
          row.timeout? ||
          row.substitution? ||
          row.offensive_foul_turnover? ||
          row.double_technical_foul? ||
          [ :unknown, :defensive_violation, :ejection, :period_start ].include?(row.event) ||
          (row.shooting_foul? && row.previous_row.and_one?) ||
          (row.jump_ball? && possession.period < 5 && possession.opening_tip)
      end

      def self.validate_score!(possession, row)
        score = "#{possession.visitor.points} - #{possession.home.points}"
        if row.score && row.score != score
          raise Model::InvalidStateError, "row score #{row.score} does not match possession score #{score}"
        end
      end

      def self.find_play_by_eventnum!(game, eventnum)
        play = game.plays.detect { |p| p.row.eventnum == eventnum }
        raise(ArgumentError, "No play with eventnum #{eventnum}") unless play
        play
      end

      def self.debug(possession, row)
        return unless PlayByPlay.logger.debug?
        PlayByPlay.logger.debug possession.to_h
        PlayByPlay.logger.debug row
      end

      def self.debug_play(possession, model_play)
        return unless PlayByPlay.logger.debug?
        PlayByPlay.logger.debug possession.key => model_play.key
      end
    end
  end
end
