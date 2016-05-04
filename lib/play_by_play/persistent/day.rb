module PlayByPlay
  module Persistent
    class Day
      attr_accessor :id
      attr_reader :date
      attr_reader :games
      attr_reader :name
      attr_reader :season

      def initialize(date: nil, games: [], id: nil, name: nil, season: nil)
        @games = games
        @id = id
        @name = name
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
