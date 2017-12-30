require "json"
require "play_by_play/sample/row"
require "play_by_play/model/game_play"
require "play_by_play/model/play"
require "play_by_play/model/possession"
require "play_by_play/model/invalid_state_error"
require "play_by_play/persistent/game"
require "play_by_play/persistent/play"
require "play_by_play/persistent/possession"
require "play_by_play/repository"

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
        model_possession = Model::Possession.new

        rows(game, json).each do |row|
          debug model_possession, row
          next if ignore?(model_possession, row)

          begin
            row.possession = model_possession
            row = correct_row(row, game.nba_id)

            play = play!(row.play_type, row.play_attributes)
            play.row = row

            model_possession = Model::GamePlay.play!(model_possession, model_play)
            debug_play model_possession, model_play
            validate_score! model_possession, row
            break if model_possession.errors?

            possession = Persistent::Possession.new(model_possession.attributes)
            possession.game = game
            game.possessions << possession
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
        model_play = Model::Play.new(play_type, play_attributes)
        play = Persistent::Play.from_model(model_play, game.possession)
        game.possession.play = play
        play.possession = game.possession
        play
      end

      # Map JSON array to Sample::Row
      def self.rows(game, json)
        headers = json["resultSets"].first["headers"]
        json["resultSets"].first["rowSet"].each do |json_row|
          game.rows << Row.new(headers, json_row, game)
        end
        game.rows
      end

      # Source data may have specific problems
      # Change to correct_play
      def self.correct_row(row, nba_id)
        if row.misidentified_shooting_foul?
          row.eventmsgactiontype = 2
        end

        if nba_id == "0021400009" && row.eventnum == 393
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

      def self.debug_play(possession, play)
        return unless PlayByPlay.logger.debug?
        PlayByPlay.logger.debug possession.key => play.key
      end
    end
  end
end
