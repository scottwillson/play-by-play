require "play_by_play/model/play"

module PlayByPlay
  module Simulation
    module GeneratorHelper
      def expect_play(probability, game, generator)
        attributes = generator.new_play(game.possession, probability)
        play = Model::Play.new(*attributes)
        key = play.key
        expect(key)
      end
    end
  end
end
