module PlayByPlay
  module Persistent
    class Season
      attr_reader :days
      attr_reader :league

      def initialize(days: [], league: League.new)
        @days = days
        @league = league
      end

      def games
        days.map(&:games).flatten
      end

      def teams
        @league.teams
      end
    end
  end
end
