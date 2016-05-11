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
          game = Game.new_game("001", "GSW", "POR")

          Game.play! game, :jump_ball, team: :visitor
          Game.play! game, :personal_foul, team: :defense
          Game.play! game, :personal_foul, team: :defense
          Game.play! game, :fg, point_value: 3, assisted: true
          Game.play! game, :fg, point_value: 3, assisted: true
          Game.play! game, :fg, point_value: 3, assisted: true
          Game.play! game, :fg_miss
          Game.play! game, :rebound, team: :defense
          Game.play! game, :fg, point_value: 3

          repository = Repository.new
          repository.reset!
          repository.save_game game

          play_probability_distribution = Sample::PlayProbabilityDistribution.new(repository)
          possession = Model::Possession.new(ball_in_play: true)

          possession_play_probability_distribution = play_probability_distribution.for(possession)
          expect(possession_play_probability_distribution.size).to eq(13)
          expect(possession_play_probability_distribution.map(&:probability)).to match_array([ 1 ] + [ 0 ] * 12)

          possession = Model::Possession.new
          possession_play_probability_distribution = play_probability_distribution.for(possession)
          expect(possession_play_probability_distribution.size).to eq(12)
          expect(possession_play_probability_distribution.map(&:probability)).to match_array([ 1 ] + [ 0 ] * 11)

          possession = Model::Possession.new(team: :visitor)
          possession_play_probability_distribution = play_probability_distribution.for(possession)
          expect(possession_play_probability_distribution.size).to eq(27)
          expect(possession_play_probability_distribution.map(&:probability)).to match_array([ 3, 2, 1, 1 ] + [ 0 ] * 23)

          possession = Model::Possession.new(team: :home)
          possession_play_probability_distribution = play_probability_distribution.for(possession)
          expect(possession_play_probability_distribution.size).to eq(27)
          expect(possession_play_probability_distribution.map(&:probability)).to match_array([ 3, 2, 1, 1 ] + [ 0 ] * 23)
        end
      end
    end
  end
end
