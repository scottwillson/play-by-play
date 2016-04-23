require "spec_helper"
require "play_by_play/model/duplication"
require "play_by_play/model/possession"
require "play_by_play/model/team"

module PlayByPlay
  module Model
    RSpec.describe Duplication do
      describe "#merge" do
        it "merges nested hashes" do
          possession = Possession.new(home: { points: 3 })
          expect(possession.home.points).to eq(3)

          possession = possession.merge(home: { period_personal_fouls: 2 })

          expect(possession.home.points).to eq(3)
          expect(possession.home.period_personal_fouls).to eq(2)
        end
      end
    end
  end
end
