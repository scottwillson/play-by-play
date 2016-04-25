require "spec_helper"
require "play_by_play/mock/repository"
require "play_by_play/sample/play"
require "play_by_play/simulation/game"
require "play_by_play/simulation/random_play_generator"

module PlayByPlay
  module Simulation
    RSpec.describe Game do
      describe ".play!" do
        it "plays a game" do
          random_play_generator = RandomPlayGenerator.new(Mock::Repository.new)
          game = Game.new(random_play_generator: random_play_generator)
          possession = game.play!
          expect(possession.visitor.points).to be > 0
          expect(possession.home.points).to be > 0
        end
      end
    end
  end
end
