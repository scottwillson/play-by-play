require "json"
require "play_by_play/sample/day"

module PlayByPlay
  module Sample
    class Season
      attr_reader :days

      def self.import(path, repository: Repository.new, invalid_state_error: true)
        days = Dir.glob("#{path}/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].json").map do |file_path|
          json = JSON.parse(File.read(file_path))
          day = Day.parse(json)
          day.games.each { |game| game.import(path, repository: repository, invalid_state_error: invalid_state_error) }
          day
        end
        Season.new days
      end

      def initialize(days = nil)
        @days = days
      end

      def games
        @game ||= days.map(&:games).flatten
      end
    end
  end
end
