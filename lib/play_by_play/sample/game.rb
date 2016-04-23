require "json"
require "play_by_play/sample/play"
require "play_by_play/sample/row"
require "play_by_play/model/game_play"
require "play_by_play/model/play"
require "play_by_play/model/possession"
require "play_by_play/model/invalid_state_error"
require "play_by_play/repository"

module PlayByPlay
  module Sample
    class Game
      attr_reader :plays
      attr_reader :errors
      attr_accessor :error_eventnum
      attr_reader :game_id
      attr_accessor :headers
      attr_reader :id
      attr_reader :home_team_name
      attr_reader :rows
      attr_reader :visitor_team_name

      def initialize(game_id, visitor_team_name, home_team_name)
        @plays = []
        @game_id = game_id
        @headers = []
        @home_team_name = home_team_name
        @visitor_team_name = visitor_team_name
      end

      def import(path, repository: Repository.new, invalid_state_error: true)
        json = read_json(path)
        game = parse(json, invalid_state_error)
        @errors = game.errors
        @id = repository.save_game(self)
        repository.save_sample_plays plays
        repository.save_rows rows
        game.errors?
      end

      def read_json(path)
        JSON.parse(File.read("#{path}/#{game_id}.json"))
      end

      def parse(json, invalid_state_error = true)
        @headers = json["resultSets"].first["headers"]
        create_rows json

        possession = Model::Possession.new

        rows.each do |row|
          debug(possession, row)

          next if ignore?(possession, row)

          begin
            row.possession = possession
            row = correct_row(row)
            model_play = Model::Play.new(row.play_type, row.play_attributes)
            debug_play possession, model_play
            play = Play.new(possession, model_play.key, row)
            plays << play
            possession = Model::GamePlay.play!(possession, model_play)
            validate_score!(possession, row)
            break if possession.errors?
          rescue Model::InvalidStateError, ArgumentError => e
            raise e if invalid_state_error
            self.error_eventnum = row.eventnum
            possession.errors << e.message
            break
          end
        end

        PlayByPlay.logger.info(sample_game: :parse, game_id: game_id, errors: possession.errors)

        possession
      end

      # Map JSON array to Sample::Row
      def create_rows(json)
        @rows = json["resultSets"].first["rowSet"].map do |json_row|
          Row.new(self, json_row)
        end
      end

      # Source data may have specific problems
      # Change to correct_play
      def correct_row(row)
        if row.personal_foul? && !row.possession.team_instance(row.team).next_foul_in_penalty? && row.next_row.event == :ft
          row.eventmsgactiontype = 2
        end

        if game_id == "0021400009" && row.eventnum == 393
          row.eventmsgactiontype = 7
        end

        row
      end

      def ignore?(possession, row)
        uncounted_team_rebound?(possession, row) ||
          row.timeout? ||
          row.substitution? ||
          row.offensive_foul_turnover? ||
          row.double_technical_foul? ||
          [ :unknown, :defensive_violation, :ejection, :period_start ].include?(row.event) ||
          (row.shooting_foul? && row.previous_row.and_one?)
      end

      # FT miss with more FTs upcoming count as team rebounds (doesn't count in stats)
      # Block + ball out of bounds off shooter: team rebounds
      # Missed shot + out of bounds off other team
      # Missed live FT  + out of bounds off other team
      # Missed shot at end of period
      def uncounted_team_rebound?(possession, row)
        row.team_rebound? && (possession.free_throws? || possession.seconds_remaining == 720 || row&.previous_row&.technical_ft_miss?)
      end

      def validate_score!(possession, row)
        score = "#{possession.visitor.points} - #{possession.home.points}"
        if row.score && row.score != score
          raise Model::InvalidStateError, "row score #{row.score} does not match possession score #{score}"
        end
      end

      def find_play_by_eventnum!(eventnum)
        play = plays.detect { |a| a.row.eventnum == eventnum }
        raise(ArgumentError, "No play with eventnum #{eventnum}") unless play
        play
      end

      def debug(possession, row)
        return unless PlayByPlay.logger.debug?
        PlayByPlay.logger.debug possession.to_h
        PlayByPlay.logger.debug row
      end

      def debug_play(possession, model_play)
        return unless PlayByPlay.logger.debug?
        PlayByPlay.logger.debug possession.key => model_play.key
      end
    end
  end
end
