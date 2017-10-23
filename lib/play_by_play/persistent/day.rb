module PlayByPlay
  module Persistent
    class Day
      attr_accessor :id
      attr_reader :date
      attr_reader :games
      attr_reader :name
      attr_reader :season
      attr_reader :season_id

      def initialize(date: nil, games: [], id: nil, name: nil, season: nil, season_id: nil)
        @date = date
        self.games = games
        @id = id
        @name = name
        self.season = season
        @season_id = season_id
      end

      def games=(games)
        games.each do |game|
          game.day = self
        end
        @games = games
      end

      def season=(season)
        season.days << self if season&.days
        @season = season
      end

      def inspect
        to_s
      end

      def to_s
        "#<PlayByPlay::Persistent::Day>"
      end
    end
  end
end
