require "json"
require "play_by_play/persistent/day"
require "play_by_play/sample/game"

module PlayByPlay
  module Sample
    class Day
      def self.parse(json)
        games = json["resultSets"][0]["rowSet"].map do |row|
          parse_row row
        end
        Persistent::Day.new games: games
      end

      def self.parse_row(row)
        visitor = row[5][%r{/(\w\w\w)}, 1]
        home = row[5][%r{/\w\w\w(\w\w\w)}, 1]
        Sample::Game.new(row[2], visitor, home)
      end
    end
  end
end
