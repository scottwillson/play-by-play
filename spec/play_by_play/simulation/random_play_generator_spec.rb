require "spec_helper"
require "play_by_play/mock/repository"
require "play_by_play/persistent/game"
require "play_by_play/simulation/random_play_generator"

module PlayByPlay
  module Simulation
    RSpec.describe RandomPlayGenerator do
      let(:repository) { Mock::Repository.new }

      describe ".choose_play" do
        it "returns an Play" do
          repository.populate!
          generator = RandomPlayGenerator.new(repository)
          game = Persistent::Game.new(home: Persistent::Team.new(id: 0), visitor: Persistent::Team.new(id: 1))
          play = generator.new_play(game.possession)
          expect(play).to_not be(nil)
        end
      end

      describe ".random_sample" do
        context "one choice" do
          it "always chooses the play" do
            play = [ :jump_ball, team: :home, teammate: 0, player: 0, opponent: 0 ]
            repository.reset!
            game = Mock::Game.new_persistent
            repository.games.save game
            repository.plays.save({game: game} => play)
            generator = RandomPlayGenerator.new(repository)

            game = Persistent::Game.new(home: Persistent::Team.new(id: 0), visitor: Persistent::Team.new(id: 1))
            expect_play(0, game, generator).to eq([ :jump_ball, team: :home ])
            expect_play(0.5, game, generator).to eq([ :jump_ball, team: :home ])
            expect_play(0.999999, game, generator).to eq([ :jump_ball, team: :home ])
          end
        end

        context "equal choices" do
          it "chooses equally" do
            repository.reset!
            game = Mock::Game.new_persistent
            repository.games.save game
            repository.plays.save({ game: game } => [ :jump_ball, team: :home, teammate: 0, player: 0, opponent: 0 ])
            repository.plays.save({ game: game } => [ :jump_ball, team: :visitor, teammate: 0, player: 0, opponent: 0 ])
            generator = RandomPlayGenerator.new(repository)

            # rely on ordering in mock and RandomPlayGenerator
            expect_play(0, game, generator).to eq([ :jump_ball, team: :home ])
            expect_play(0.2499, game, generator).to eq([ :jump_ball, team: :home ])
            expect_play(0.25, game, generator).to eq([ :jump_ball, team: :visitor ])
            expect_play(0.4999, game, generator).to eq([ :jump_ball, team: :visitor ])
            expect_play(0.5, game, generator).to eq([ :jump_ball, team: :home ])
            expect_play(0.7499, game, generator).to eq([ :jump_ball, team: :home ])
            expect_play(0.75, game, generator).to eq([ :jump_ball, team: :visitor ])
            expect_play(0.9999, game, generator).to eq([ :jump_ball, team: :visitor ])
          end
        end

        context "no choices" do
          it "raises an exception" do
            repository.reset!
            game = Persistent::Game.new(home: Persistent::Team.new(id: 0), visitor: Persistent::Team.new(id: 1))
            expect { RandomPlayGenerator.new(repository).new_play(game.possession, 0.5) }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
