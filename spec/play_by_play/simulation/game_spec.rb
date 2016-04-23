require "spec_helper"
require "play_by_play/mock/repository"
require "play_by_play/sample/play"
require "play_by_play/simulation/game"

module PlayByPlay
  module Simulation
    RSpec.describe Game do
      describe ".play!" do
        it "plays a game" do
          repository = Mock::Repository.new
          game = Game.new(repository)
          possession = game.play!
          expect(possession.visitor.points).to be > 0
          expect(possession.home.points).to be > 0
        end
      end
    end
  end
end
