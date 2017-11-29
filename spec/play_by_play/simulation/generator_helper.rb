require "play_by_play/model/play"

module PlayByPlay
  module Simulation
    module GeneratorHelper
      def expect_play(random_number, game, generator)
        attributes = generator.new_play(game.possession, random_number)
        play = Model::Play.new(*attributes)
        key = play.key
        expect(key)
      end
    end
  end
end
