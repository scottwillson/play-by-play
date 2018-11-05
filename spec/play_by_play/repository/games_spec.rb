require "spec_helper"
require "play_by_play/mock/repository"
require "play_by_play/persistent/game"
require "play_by_play/repository"
require "play_by_play/simulation/game"
require "play_by_play/simulation/season"
require "play_by_play/simulation/random_play_generator"
require "play_by_play/simulation/random_seconds_generator"

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
      it "saves possessions with current score margin", database: true do
        repository = Repository.new
        repository.reset!

        home = Persistent::Team.new(abbreviation: "SEA")
        13.times do |index|
          home.players << Persistent::Player.new(name: "Home Player #{index}")
        end

        visitor = Persistent::Team.new(abbreviation: "POR")
        13.times do |index|
          visitor.players << Persistent::Player.new(name: "Visitor Player #{index}")
        end

        repository.teams.save home
        repository.teams.save visitor

        season = Simulation::Season.new_persistent
        day = Persistent::Day.new(season: season)
        game = Persistent::Game.new(home: home, visitor: visitor, day: day)
        repository.seasons.save season

        mock_repository = Mock::Repository.new
        mock_repository.populate!

        random_play_generator = Simulation::RandomPlayGenerator.new(mock_repository)
        random_seconds_generator = Simulation::RandomSecondsGenerator.new(mock_repository)
        game = Simulation::Game.play!(game, random_play_generator, random_seconds_generator)

        repository.games.save_possessions game

        possessions = repository.games.possessions(game.id)
        expect(possessions.last.visitor_margin).not_to eq(0)
        expect(possessions.last.home_margin).not_to eq(0)
        expect(possessions.last.home_margin + game.possession.visitor_margin).to eq(0)
      end
    end
  end
end
