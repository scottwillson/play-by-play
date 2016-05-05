require "play_by_play/model/invalid_state_error"
require "play_by_play/persistent/season"
require "play_by_play/persistent/team"
require "play_by_play/repository"
require "play_by_play/simulation/conference"
require "play_by_play/simulation/day"
require "play_by_play/simulation/league"

module PlayByPlay
  module Simulation
    class Season < Persistent::Season
      attr_reader :random_play_generator
      attr_reader :repository
      attr_reader :scheduled_games_per_teams_count

      def initialize(attributes)
        attributes = attributes.dup
        @repository = attributes.delete(:repository) || Repository.new
        @scheduled_games_per_teams_count = (attributes.delete(:scheduled_games_per_teams_count) || 82).to_i
        attributes[:league] = attributes[:league] || League.new(30)

        raise(Model::InvalidStateError, "scheduled_games_per_teams_count must be even but was #[scheduled_games_per_teams_count]") if scheduled_games_per_teams_count.odd?

        super attributes

        @random_play_generator = RandomPlayGenerator.new(repository)

        scheduled_games_count = league.teams.size * (scheduled_games_per_teams_count / 2)
        create_days scheduled_games_count

        league.teams.each do |team|
          if scheduled_games_per_teams_count != team.games.size
            raise(Model::InvalidStateError, "#{team.name} has #{team.games.size} instead of #{scheduled_games_per_teams_count}")
          end
        end
      end

      def create_days(scheduled_games_count)
        date = Date.today
        @days = []
        while games.size < scheduled_games_count
          games_to_go = scheduled_games_count - games.size

          if games_to_go > 12
            games_to_go = rand(12) + 1
          end

          @days << Day.new(date: date += 1, number_of_games: games_to_go, season: self)
        end
      end

      def play!
        days.each(&:play!)
        self
      end
    end
  end
end
