require "play_by_play/model/game_play"
require "play_by_play/model/invalid_state_error"
require "play_by_play/model/possession"
require "play_by_play/persistent/game"
require "play_by_play/persistent/team"
require "play_by_play/repository"
require "play_by_play/simulation/random_play_generator"

module PlayByPlay
  module Simulation
    class Game < Persistent::Game
      def initialize(attributes)
        attributes = attributes.dup
        @random_play_generator = attributes.delete(:random_play_generator)
        super attributes

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

      def random_play_generator
        @random_play_generator ||= RandomPlayGenerator.new(PlayByPlay::Repository.new)
      end
    end
  end
end
