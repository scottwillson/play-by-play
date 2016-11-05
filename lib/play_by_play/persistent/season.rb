require "play_by_play/persistent/league"

module PlayByPlay
  module Persistent
    class Season
      attr_reader :days
      attr_accessor :id
      attr_reader :league
      attr_reader :start_at

      def initialize(days: [], id: nil, league: League.new, start_at: nil)
        @days = days
        @id = id
        @league = league
        @start_at = start_at
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
