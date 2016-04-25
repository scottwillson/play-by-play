require "play_by_play/model/game_play"
require "play_by_play/model/invalid_state_error"
require "play_by_play/model/possession"
require "play_by_play/repository"
require "play_by_play/simulation/random_play_generator"
require "play_by_play/simulation/team"

module PlayByPlay
  module Simulation
    class Game
      attr_reader :home
      attr_reader :possessions
      attr_reader :visitor

      def initialize(home: Team.new(key: :home), visitor: Team.new(key: :visitor), random_play_generator: nil)
        @home = home
        @possessions = [ Model::Possession.new ]
        @random_play_generator = random_play_generator
        @visitor = visitor

        raise(Model::InvalidStateError, "Team cannot play itself") if home == visitor

        @home.games << self
        @visitor.games << self
      end

      def play!
        until possession.game_over?
          play = random_play_generator.new_play(possession)
          possessions << Model::GamePlay.play!(possession, play)

          if possessions.size > 3_000
            raise Model::InvalidStateError, "Game not over after #{possessions.size} plays"
          end
        end

        possession
      end

      def possession
        possessions.last
      end

      def loser
        return unless possession.game_over?

        if possession.home.points < possession.visitor.points
          home
        else
          visitor
        end
      end

      def winner
        return unless possession.game_over?

        if possession.home.points > possession.visitor.points
          home
        else
          visitor
        end
      end

      def random_play_generator
        @random_play_generator ||= RandomPlayGenerator.new(PlayByPlay::Repository.new)
      end
    end
  end
end
