require "play_by_play/persistent/league"

module PlayByPlay
  module Persistent
    class Season
      attr_accessor :days
      attr_accessor :id
      attr_accessor :league
      attr_accessor :source
      attr_reader :start_at

      def self.new_sample(**args)
        raise(ArgumentError("source must be unspecified")) if args[:source]
        raise(ArgumentError("start_at must be unspecified")) if args[:start_at]
        args[:source] = "sample"
        args[:start_at] = Date.today
        self.new args
      end

      def self.new_simulation(**args)
        raise(ArgumentError("source must be unspecified")) if args[:source]
        raise(ArgumentError("start_at must be unspecified")) if args[:start_at]
        args[:source] = "simulation"
        args[:start_at] = Date.today
        self.new args
      end

      def initialize(days: [], id: nil, league: League.new, source: nil, start_at: nil)
        @days = days
        @id = id
        @league = league
        @source = source
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
