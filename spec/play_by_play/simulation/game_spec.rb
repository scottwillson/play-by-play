require "spec_helper"
require "play_by_play/mock/repository"
require "play_by_play/persistent/game"
require "play_by_play/simulation/game"
require "play_by_play/simulation/random_play_generator"
require "play_by_play/simulation/random_seconds_generator"

module PlayByPlay
  module Simulation
    RSpec.describe Game do
      describe ".play!" do
        it "plays a game" do
          repository = Mock::Repository.new
          random_play_generator = RandomPlayGenerator.new(repository)
          random_seconds_generator = RandomSecondsGenerator.new(repository)
          game = Persistent::Game.new(home: Persistent::Team.new(id: 0), visitor: Persistent::Team.new(id: 1))
          game = Game.play!(game, random_play_generator, random_seconds_generator)
          expect(game.possession.visitor.points).to be > 0
          expect(game.possession.home.points).to be > 0
          expect(game.possession.margin(:visitor)).not_to eq(0)
          expect(game.possession.margin(:home)).not_to eq(0)
        end
      end
    end
  end
end
