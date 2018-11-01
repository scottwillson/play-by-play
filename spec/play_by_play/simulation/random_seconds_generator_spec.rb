require "spec_helper"
require "play_by_play/mock/repository"
require "play_by_play/persistent/game"
require "play_by_play/persistent/play"
require "play_by_play/sample/season"
require "play_by_play/simulation/random_seconds_generator"

module PlayByPlay
  module Simulation
    RSpec.describe RandomSecondsGenerator do
      let(:repository) { Mock::Repository.new }

      describe ".seconds" do
        it "returns random sample of play seconds" do
          repository.populate!

          game = repository.games.all[0]
          play = Persistent::Play.new(:jump_ball, team: :home, possession: game.possessions.first, teammate: 0, player: 0, opponent: 0, seconds: 2)
          repository.plays.save play

          game = Mock::Game.new_persistent("POR", "GSW", "0021400015")
          repository.games.save game
          possession = game.possession
          possession.play = Persistent::Play.new(:jump_ball, team: :home, possession: game.possessions.first, teammate: 0, player: 0, opponent: 0)

          generator = RandomSecondsGenerator.new(repository)
          seconds = generator.seconds(possession)

          expect(seconds).to eq(2)
        end
      end

      describe ".random_sample" do
        context "one choice" do
          it "always chooses the seconds for that play" do
            repository.reset!
            repository.plays.save({} => [ :jump_ball, team: :home, teammate: 0, player: 0, opponent: 0, seconds: 3 ])
            generator = RandomSecondsGenerator.new(repository)

            game = Persistent::Game.new(home: Persistent::Team.new(id: 0), visitor: Persistent::Team.new(id: 1))
            game.possession.play = Persistent::Play.new(:jump_ball, team: :home, teammate: 0, player: 0, opponent: 0)
            expect(generator.seconds(game.possession, 0)).to eq(3)
            expect(generator.seconds(game.possession, 0.5)).to eq(3)
            expect(generator.seconds(game.possession, 0.999999)).to eq(3)
          end
        end

        context "no choices" do
          it "raises an exception" do
            repository.reset!
            game = Mock::Game.new_persistent
            repository.games.save game
            game.possession.play = Persistent::Play.new(
              :jump_ball,
              possession: game.possession,
              team: :visitor,
              teammate: 0,
              player: 0,
              opponent: 0
            )
            expect { RandomSecondsGenerator.new(repository).seconds(game.possession, 0.5) }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
