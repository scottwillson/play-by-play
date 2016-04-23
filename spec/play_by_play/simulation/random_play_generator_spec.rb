require "spec_helper"
require "play_by_play/mock/repository"
require "play_by_play/model/possession"
require "play_by_play/sample/play"
require "play_by_play/simulation/random_play_generator"

module PlayByPlay
  module Simulation
    RSpec.describe RandomPlayGenerator do
      let(:repository) { Mock::Repository.new }

      describe ".choose_play" do
        it "returns an Play" do
          generator = RandomPlayGenerator.new(repository)
          play = generator.new_play(Model::Possession.new)
          expect(play).to_not be(nil)
        end
      end

      describe ".random_sample" do
        context "one choice" do
          it "always chooses the play" do
            play = [ :jump_ball, team: :home ]
            repository.reset!
            repository.save_sample_play({} => play)
            generator = RandomPlayGenerator.new(repository)

            possession = Model::Possession.new
            expect(generator.new_play(possession, 0)).to eq(play)
            expect(generator.new_play(possession, 0.5)).to eq(play)
            expect(generator.new_play(possession, 0.999999)).to eq(play)
          end
        end

        context "two equal choices" do
          it "chooses equally" do
            repository.reset!
            repository.save_sample_play({} => [ :jump_ball, team: :home ])
            repository.save_sample_play({} => [ :jump_ball, team: :home ])
            generator = RandomPlayGenerator.new(repository)

            possession = Model::Possession.new
            expect(generator.new_play(possession, 0)).to eq([ :jump_ball, team: :home ])
            expect(generator.new_play(possession, 0.49999)).to eq([ :jump_ball, team: :home ])
            expect(generator.new_play(possession, 0.5)).to eq([ :jump_ball, team: :home ])
            expect(generator.new_play(possession, 0.9999)).to eq([ :jump_ball, team: :home ])
          end
        end

        context "no choices" do
          it "raises an exception" do
            repository.reset!
            possession = Model::Possession.new
            expect { RandomPlayGenerator.new(repository).new_play(possession, 0.5) }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
