require "spec_helper"
require "play_by_play/mock/repository"
require "play_by_play/persistent/game"
require "play_by_play/sample/season"
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
            play = [ :jump_ball, team: :home, teammate: 0, player: 2, opponent: 0 ]
            repository.reset!
            repository.plays.save_hash({} => play)
            generator = RandomPlayGenerator.new(repository)

            game = Persistent::Game.new(home: Persistent::Team.new(id: 0), visitor: Persistent::Team.new(id: 1))
            expect(generator.new_play(game.possession, 0).key).to eq(play)
            expect(generator.new_play(game.possession, 0.5).key).to eq(play)
            expect(generator.new_play(game.possession, 0.999999).key).to eq(play)
          end
        end

        context "two equal choices" do
          it "chooses equally" do
            repository.reset!
            repository.plays.save_hash({} => [ :jump_ball, team: :home, teammate: 0, player: 2, opponent: 0 ])
            repository.plays.save_hash({} => [ :jump_ball, team: :home, teammate: 0, player: 2, opponent: 0 ])
            generator = RandomPlayGenerator.new(repository)

            game = Persistent::Game.new(home: Persistent::Team.new(id: 0), visitor: Persistent::Team.new(id: 1))
            expect(generator.new_play(game.possession, 0).key).to eq([ :jump_ball, team: :home ])
            expect(generator.new_play(game.possession, 0.49999).key).to eq([ :jump_ball, team: :home ])
            expect(generator.new_play(game.possession, 0.5).key).to eq([ :jump_ball, team: :home ])
            expect(generator.new_play(game.possession, 0.9999).key).to eq([ :jump_ball, team: :home ])
          end
        end

        context "more choices for one team" do
          it "adjusts for number of choices" do
            repository = Repository.new
            repository.reset!

            season = Sample::Season.new_persistent
            day = Persistent::Day.new(season: season)
            game = Sample::Game.new_game("001", "GSW", "POR")
            game.day = day

            # start game
            Persistent::GamePlay.add_play(game, Model::Play.new(:jump_ball, team: :home))

            # GSW team is 1 for 2
            Persistent::GamePlay.add_play(game, Model::Play.new(:fg_miss))
            Persistent::GamePlay.add_play(game, Model::Play.new(:rebound, team: :offense))
            Persistent::GamePlay.add_play(game, Model::Play.new(:fg))

            gsw = game.home

            game = Sample::Game.new_game("002", "NYK", "MIN")
            game.day = day

            # start game
            Persistent::GamePlay.add_play(game, Model::Play.new(:jump_ball, team: :home))

            # MIN opponents are 1 for 5
            Persistent::GamePlay.add_play(game, Model::Play.new(:fg_miss))
            Persistent::GamePlay.add_play(game, Model::Play.new(:rebound, team: :offense))
            Persistent::GamePlay.add_play(game, Model::Play.new(:fg_miss))
            Persistent::GamePlay.add_play(game, Model::Play.new(:rebound, team: :offense))
            Persistent::GamePlay.add_play(game, Model::Play.new(:fg_miss))
            Persistent::GamePlay.add_play(game, Model::Play.new(:rebound, team: :offense))
            Persistent::GamePlay.add_play(game, Model::Play.new(:fg_miss))
            Persistent::GamePlay.add_play(game, Model::Play.new(:rebound, team: :offense))
            Persistent::GamePlay.add_play(game, Model::Play.new(:fg))

            repository.seasons.save season

            wolves = game.visitor

            generator = RandomPlayGenerator.new(repository)

            game = Persistent::Game.new(home: gsw, visitor: wolves)

            Persistent::GamePlay.add_play(game, Model::Play.new(:jump_ball, team: :home))

            # GSW shoots 1-2, MIN opponents shoot 1-4 = 30% (not 40%)
            # TODO do math right
            # TODO move to PlayProbabilityDistribution spec
            expect(generator.new_play(game.possession, 0).key).to eq([ :fg ])
            expect(generator.new_play(game.possession, 0.29999).key).to eq([ :fg ])
            expect(generator.new_play(game.possession, 0.3).key).to eq([ :fg_miss ])
            expect(generator.new_play(game.possession, 0.99999).key).to eq([ :fg_miss ])
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
