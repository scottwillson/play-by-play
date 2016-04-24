require "play_by_play/model/invalid_state_error"
require "play_by_play/simulation/game"

module PlayByPlay
  module Simulation
    class Day
      attr_reader :date

      def initialize(season, number_of_games = nil, date = nil)
        @date = date
        @season = season

        teams = season.teams.select { |team| team.games.size < season.scheduled_games_per_teams_count }
        raise(Model::InvalidStateError, "All teams have played #{season.scheduled_games_per_teams_count} games") if teams.size == 0
        raise(Model::InvalidStateError, "Only #{teams.first.name} has played fewer than #{season.scheduled_games_per_teams_count} games") if teams.size == 1

        (number_of_games || (rand(12) + 1)).times do
          home = teams.sample
          visitor = (teams - [ home ]).sample
          game = Game.new(home: home, repository: season.repository, visitor: visitor)
          self.games << game
        end
      end

      def games
        @games ||= []
      end

      def play!
        @games.each(&:play!)
      end
    end
  end
end
