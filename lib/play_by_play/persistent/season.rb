require "play_by_play/persistent/league"

module PlayByPlay
  module Persistent
    class Season
      attr_accessor :days
      attr_accessor :id
      attr_accessor :league
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

      def losses(team)
        games.select { |game| game.loser == team }.size
      end

      def team(id)
        teams.find { |team| team.id == id }
      end

      def teams
        @league.teams
      end

      def wins(team)
        games.select { |game| game.winner == team }.size
      end
    end
  end
end
