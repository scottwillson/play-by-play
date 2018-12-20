require "spec_helper"
require "play_by_play/sample/play_probability"
require "play_by_play/model/possession"

module PlayByPlay
  module Sample
    RSpec.describe PlayProbability do
      describe ".new" do
        it "creates a PlayProbability" do
          play_probability = PlayProbability.new(0.25, :ft)
          expect(play_probability.probability).to eq(0.25)
          expect(play_probability.play).to eq([ :ft ])
        end

        it "creates a PlayProbability with complex play" do
          play_probability = PlayProbability.new(0.1, :fg, point_value: 3, and_one: true, assisted: true)
          expect(play_probability.probability).to eq(0.1)
          expect(play_probability.play).to eq([ :fg, point_value: 3, and_one: true, assisted: true ])
        end
      end
    end
  end
end
