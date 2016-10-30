require "spec_helper"
require "play_by_play/model/play"
require "play_by_play/model/possession"
require "play_by_play/sample/game"
require "play_by_play/sample/play_probability_distribution"
require "play_by_play/repository"

module PlayByPlay
  module Sample
    RSpec.describe PlayProbabilityDistribution do
      describe ".for" do
        it "returns instances of PlayProbability", database: true do
          sample_game = Game.new_game("001", "GSW", "POR")

          Game.play! sample_game, :jump_ball, team: :visitor
          Game.play! sample_game, :personal_foul, team: :defense # home (visitor on offense)
          Game.play! sample_game, :personal_foul, team: :defense # home (visitor on offense)
          Game.play! sample_game, :fg, point_value: 3, assisted: true # visitor
          Game.play! sample_game, :fg, point_value: 3, assisted: true # home
          Game.play! sample_game, :fg, point_value: 3, assisted: true # visitor
          Game.play! sample_game, :fg_miss # home
          Game.play! sample_game, :rebound, team: :defense # visitor
          Game.play! sample_game, :fg, point_value: 3 # visitor

          repository = Repository.new
          repository.reset!
          repository.save_game sample_game

          game = Persistent::Game.new(home: repository.team(sample_game.home.id), visitor: repository.team(sample_game.visitor.id))
          play_probability_distribution = Sample::PlayProbabilityDistribution.new(repository)

          possession = Persistent::Possession.new(game: game)
          expect(possession.key).to be_nil
          possession_play_probability_distribution = play_probability_distribution.for(game.possession)
          expect(possession_play_probability_distribution.size).to eq(12)
          expect(possession_play_probability_distribution.map(&:probability)).to match_array([ 1 ] + [ 0 ] * 11)

          possession = Persistent::Possession.new(game: game, ball_in_play: true)
          possession_play_probability_distribution = play_probability_distribution.for(possession)
          expect(possession_play_probability_distribution.size).to eq(13)
          expect(possession_play_probability_distribution.map(&:probability)).to match_array([ 1 ] + [ 0 ] * 12)

          possession = Persistent::Possession.new(game: game, ball_in_play: true, offense: :visitor, team: :visitor)
          possession_play_probability_distribution = play_probability_distribution.for(possession)
          expect(possession_play_probability_distribution.size).to eq(27)
          expect(possession_play_probability_distribution.map(&:probability)).to match_array([ 2, 2, 2, 1, 1 ] + [ 0 ] * 22)

          possession = Persistent::Possession.new(game: game, ball_in_play: true, offense: :home, team: :home)
          possession_play_probability_distribution = play_probability_distribution.for(possession)
          expect(possession_play_probability_distribution.size).to eq(27)
          expect(possession_play_probability_distribution.map(&:probability)).to match_array([ 1, 1, 1 ] + [ 0 ] * 24)
        end
      end
    end
  end
end
