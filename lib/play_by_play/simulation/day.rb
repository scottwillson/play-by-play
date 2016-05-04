require "play_by_play/model/invalid_state_error"
require "play_by_play/persistent/day"
require "play_by_play/simulation/game"

module PlayByPlay
  module Simulation
    class Day < Persistent::Day
      attr_reader :date

      def initialize(attributes)
        attributes = attributes.dup
        number_of_games = attributes.delete(:number_of_games)
        super attributes

        create_games number_of_games
      end

      def create_games(number_of_games)
        teams = season.teams.select { |team| team.games.size < season.scheduled_games_per_teams_count }
                  .shuffle
                  .sort_by { |team| team.games.size }

        raise(Model::InvalidStateError, "All teams have played #{season.scheduled_games_per_teams_count} games") if teams.size == 0
        raise(Model::InvalidStateError, "Only #{teams.first.name} has played fewer than #{season.scheduled_games_per_teams_count} games") if teams.size == 1

        if number_of_games > teams.size / 2
          number_of_games = teams.size / 2
        end

        number_of_games.times do
          raise(Model::InvalidStateError, "All teams have played #{season.scheduled_games_per_teams_count} games") if teams.size == 0
          raise(Model::InvalidStateError, "Only #{teams.first.name} has played fewer than #{season.scheduled_games_per_teams_count} games") if teams.size == 1
          home = teams.pop
          visitor = teams.pop
          game = Game.new(home: home, random_play_generator: season.random_play_generator, visitor: visitor)
          self.games << game
          home.games << game
          visitor.games << game
        end
      end

      def play!
        @games.each(&:play!)
      end
    end
  end
end
