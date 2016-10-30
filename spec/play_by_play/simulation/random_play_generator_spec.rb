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
          generator = RandomPlayGenerator.new(repository)
          game = Persistent::Game.new
          play = generator.new_play(game.possession)
          expect(play).to_not be(nil)
        end
      end

      describe ".random_sample" do
        context "one choice" do
          it "always chooses the play" do
            play = [ :jump_ball, team: :home ]
            repository.reset!
            repository.save_play({} => play)
            generator = RandomPlayGenerator.new(repository)

            game = Persistent::Game.new
            expect(generator.new_play(game.possession, 0)).to eq(play)
            expect(generator.new_play(game.possession, 0.5)).to eq(play)
            expect(generator.new_play(game.possession, 0.999999)).to eq(play)
          end
        end

        context "two equal choices" do
          it "chooses equally" do
            repository.reset!
            repository.save_play({} => [ :jump_ball, team: :home ])
            repository.save_play({} => [ :jump_ball, team: :home ])
            generator = RandomPlayGenerator.new(repository)

            game = Persistent::Game.new
            expect(generator.new_play(game.possession, 0)).to eq([ :jump_ball, team: :home ])
            expect(generator.new_play(game.possession, 0.49999)).to eq([ :jump_ball, team: :home ])
            expect(generator.new_play(game.possession, 0.5)).to eq([ :jump_ball, team: :home ])
            expect(generator.new_play(game.possession, 0.9999)).to eq([ :jump_ball, team: :home ])
          end
        end

        context "no choices" do
          it "raises an exception" do
            repository.reset!
            game = Persistent::Game.new
            expect { RandomPlayGenerator.new(repository).new_play(game.possession, 0.5) }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
