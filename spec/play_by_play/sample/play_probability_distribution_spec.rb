require "spec_helper"
require "play_by_play/model/play"
require "play_by_play/model/possession"
require "play_by_play/sample/play_probability_distribution"
require "play_by_play/repository"

module PlayByPlay
  module Sample
    RSpec.describe PlayProbabilityDistribution do
      describe ".for" do
        it "returns instances of PlayProbability", database: true do
          repository = Repository.new
          repository.reset!
          repository.save_play({} => [ :jump_ball, team: :visitor ])
          repository.save_play({ ball_in_play: true } => [ :personal_foul, team: :defense ])
          repository.save_play({ ball_in_play: true } => [ :personal_foul, team: :defense ])
          repository.save_play({ ball_in_play: true } => [ :rebound, team: :defense ])
          repository.save_play({ team: :visitor } => [ :fg, point_value: 3, assisted: true ])
          repository.save_play({ team: :home }    => [ :fg, point_value: 3, assisted: true ])
          repository.save_play({ team: :visitor } => [ :fg, point_value: 3, assisted: true ])
          repository.save_play({ team: :visitor } => [ :fg, point_value: 3 ])

          play_probability_distribution = Sample::PlayProbabilityDistribution.new(repository)
          possession = Model::Possession.new(ball_in_play: true)

          possession_play_probability_distribution = play_probability_distribution.for(possession)
          expect(possession_play_probability_distribution.size).to eq(13)
          expect(possession_play_probability_distribution.map(&:probability)).to match_array([ 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ])

          possession = Model::Possession.new
          possession_play_probability_distribution = play_probability_distribution.for(possession)
          expect(possession_play_probability_distribution.size).to eq(12)
          expect(possession_play_probability_distribution.map(&:probability)).to match_array([ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ])

          possession = Model::Possession.new(team: :visitor)
          possession_play_probability_distribution = play_probability_distribution.for(possession)
          expect(possession_play_probability_distribution.size).to eq(27)
          expect(possession_play_probability_distribution.map(&:probability)).to include(3)
          expect(possession_play_probability_distribution.map(&:probability)).to include(1)
        end
      end
    end
  end
end
