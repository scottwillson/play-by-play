require "spec_helper"
require "play_by_play/sample/play_probability"
require "play_by_play/model/possession"

module PlayByPlay
  module Sample
    RSpec.describe PlayProbability do
      describe ".new" do
        it "creates a PlayProbability" do
          play = PlayProbability.new(0.25, :ft)
          expect(play.probability).to eq(0.25)
          expect(play.play).to eq(:ft)
        end
      end
    end
  end
end
