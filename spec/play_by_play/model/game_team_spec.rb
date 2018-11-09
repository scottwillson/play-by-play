require "spec_helper"
require "play_by_play/model/game_team"
require "play_by_play/model/possession"

module PlayByPlay
  module Model
    RSpec.describe GameTeam do
      describe "#merge" do
        let(:possession) { Possession.new }

        it "copies points" do
          team = possession.home

          team = team.merge(points: 3)
          expect(team.points).to eq(3)

          team = team.merge(period_personal_fouls: 1)
          expect(team.points).to eq(3)
          expect(team.period_personal_fouls).to eq(1)
        end
      end

      describe "#==" do
        it "considers key" do
          expect(GameTeam.new(key: :home)).to eq(GameTeam.new(key: :home))
          expect(GameTeam.new(key: :visitor)).not_to eq(GameTeam.new(key: :home))
        end
      end
    end
  end
end
