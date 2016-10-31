require "json"
require "play_by_play/persistent/season"
require "play_by_play/sample/day"
require "play_by_play/sample/game"

module PlayByPlay
  module Sample
    module Season
      def self.import(path, repository: Repository.new, invalid_state_error: true)
        days = Dir.glob("#{path}/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].json").map do |file_path|
          json = JSON.parse(File.read(file_path))
          day = Day.parse(json)
          day.games.each do |game|
            begin
              Game.import(game, path, repository: repository, invalid_state_error: invalid_state_error)
            rescue StandardError => e
              puts "Import error: #{e} for #{file_path}"
            end
          end
          day
        end
        Persistent::Season.new days: days
      end

      def self.parse(path, invalid_state_error: true)
        Dir.glob("#{path}/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].json").map do |file_path|
          json = JSON.parse(File.read(file_path))
          day = Day.parse(json)
          day.games.each do |game|
            json = PlayByPlay::Sample::Game.read_json(path, game.nba_id)
            PlayByPlay::Sample::Game.parse game, json, invalid_state_error
          end
        end
      end
    end
  end
end
