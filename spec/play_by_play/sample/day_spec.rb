require "spec_helper"
require "play_by_play/sample/day"

module PlayByPlay
  module Sample
    RSpec.describe Day do
      describe ".parse" do
        it "creates a Days of Games from JSON" do
          json = JSON.parse(File.read("spec/data/2014-10-28.json"))
          day = Day.parse(json)
          expect(day.games.size).to eq(3)
        end
      end
    end
  end
end
