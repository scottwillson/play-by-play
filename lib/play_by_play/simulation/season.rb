require "play_by_play/model/invalid_state_error"
require "play_by_play/simulation/day"
require "play_by_play/simulation/team"

module PlayByPlay
  module Simulation
    class Season
      attr_reader :days
      attr_reader :random_play_generator
      attr_reader :repository
      attr_reader :scheduled_games_count
      attr_reader :scheduled_games_per_teams_count
      attr_reader :teams_count
      attr_reader :teams

      def initialize(teams_count: 30, repository: PlayByPlay::Repository.new, scheduled_games_per_teams_count: 82)
        raise(Model::InvalidStateError, "scheduled_games_per_teams_count must be even but was #[scheduled_games_per_teams_count]") if scheduled_games_per_teams_count.odd?

        @scheduled_games_per_teams_count = scheduled_games_per_teams_count.to_i
        @teams_count = teams_count.to_i
        @random_play_generator = RandomPlayGenerator.new(repository)
        @repository = repository

        @scheduled_games_count = teams_count * (scheduled_games_per_teams_count / 2)

        create_teams
        create_days

        teams.each do |team|
          if scheduled_games_per_teams_count != team.games.size
            raise(Model::InvalidStateError, "#{team.name} has #{team.games.size} instead of #{scheduled_games_per_teams_count}")
          end
        end
      end

      def create_teams
        i = 0
        @teams = Array.new(teams_count) { Team.new("team_#{i += 1}") }
      end

      def create_days
        date = Date.today
        @days = []
        while games.size < scheduled_games_count
          games_to_go = scheduled_games_count - games.size

          if games_to_go > 12
            games_to_go = rand(12) + 1
          end

          @days << Day.new(self, games_to_go, date += 1)
        end
      end

      def home_points
        return 0 if games.size == 0
        return @home_points if @home_points

        @home_points = games.map(&:home).map(&:points).reduce(:+)
      end

      def visitor_points
        return 0 if games.size == 0
        return @visitor_points if @visitor_points

        @visitor_points = games.map(&:visitor).map(&:points).reduce(:+)
      end

      def points
        home_points + visitor_points
      end

      def games
        days.map(&:games).flatten
      end

      def play!
        days.each(&:play!)
        self
      end
    end
  end
end
