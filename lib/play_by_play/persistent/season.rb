require "play_by_play/persistent/league"

module PlayByPlay
  module Persistent
    class Season
      attr_accessor :days
      attr_accessor :id
      attr_accessor :league
      attr_accessor :source
      attr_reader :start_at

      def initialize(days: [], id: nil, league: League.new, source: nil, start_at: Date.today)
        self.days = days
        @id = id
        @league = league
        @source = source
        @start_at = start_at

        validate!
      end

      def days=(days)
        days.each do |day|
          day.season = self
        end
        @days = days
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

      def validate!
        raise(ArgumentError, "source must sample or simulation") unless [ "sample", "simulation" ].include?(source)
        raise(ArgumentError, "start_at cannot be nil") if start_at.nil?
      end
    end
  end
end
