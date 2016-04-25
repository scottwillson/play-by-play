require "play_by_play/model/invalid_state_error"
require "play_by_play/repository"
require "play_by_play/simulation/conference"
require "play_by_play/simulation/day"
require "play_by_play/simulation/league"
require "play_by_play/simulation/team"

module PlayByPlay
  module Simulation
    class Season
      attr_reader :days
      attr_reader :league
      attr_reader :random_play_generator
      attr_reader :repository
      attr_reader :scheduled_games_count
      attr_reader :scheduled_games_per_teams_count
      attr_reader :teams_count

      def initialize(league: League.new, repository: Repository.new, scheduled_games_per_teams_count: 82)
        raise(Model::InvalidStateError, "scheduled_games_per_teams_count must be even but was #[scheduled_games_per_teams_count]") if scheduled_games_per_teams_count.odd?

        @league = league
        @scheduled_games_per_teams_count = scheduled_games_per_teams_count.to_i
        @teams_count = teams_count.to_i
        @random_play_generator = RandomPlayGenerator.new(repository)
        @repository = repository

        @scheduled_games_count = league.teams.size * (scheduled_games_per_teams_count / 2)

        create_days

        league.teams.each do |team|
          if scheduled_games_per_teams_count != team.games.size
            raise(Model::InvalidStateError, "#{team.name} has #{team.games.size} instead of #{scheduled_games_per_teams_count}")
          end
        end
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

      def games
        days.map(&:games).flatten
      end

      def play!
        days.each(&:play!)
        self
      end

      def teams
        @league.teams
      end
    end
  end
end
