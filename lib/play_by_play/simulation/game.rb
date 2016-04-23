require "play_by_play/model/game_play"
require "play_by_play/model/invalid_state_error"
require "play_by_play/model/possession"
require "play_by_play/repository"
require "play_by_play/simulation/random_play_generator"

module PlayByPlay
  module Simulation
    class Game
      attr_reader :possessions

      def initialize(repository)
        @repository = repository
        @possessions = [ Model::Possession.new ]
      end

      def play!
        random_play_generator = RandomPlayGenerator.new(@repository)

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
    end
  end
end
