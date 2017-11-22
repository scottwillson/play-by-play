require "spec_helper"
require "play_by_play/mock/repository"
require "play_by_play/persistent/game"
require "play_by_play/repository"
require "play_by_play/simulation/game"

module PlayByPlay
  RSpec.describe "Repository.games" do
    describe ".all" do
      it "returns array", database: true do
        repository = Repository.new
        repository.reset!
        expect(repository.games.all).to eq([])
      end
    end

    describe ".save_possessions" do
      it "saves possessions with current score margin" do
        repository = Repository.new
        repository.reset!

        random_play_generator = Simulation::RandomPlayGenerator.new(Mock::Repository.new)
        game = Persistent::Game.new(home: Persistent::Team.new(id: 0), visitor: Persistent::Team.new(id: 1))
        game = Simulation::Game.play!(game, random_play_generator)

        repository.games.save_possessions game

        games = repository.games.all
        expect(games.size).to eq(1)
        expect(game.possession.visitor.margin).not_to eq(0)
        expect(game.possession.home.margin).not_to eq(0)
        expect(game.possession.home.margin - game.possession.visitor.margin).to eq(0)
      end
    end
  end
end
