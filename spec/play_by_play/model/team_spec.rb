require "spec_helper"
require "play_by_play/model/possession"
require "play_by_play/model/team"

module PlayByPlay
  module Model
    RSpec.describe Team do
      describe "next_foul_in_penalty?" do
        let(:possession) { Possession.new }

        context "#merge" do
          it "copies points" do
            team = possession.home

            team = team.merge(points: 3)
            expect(team.points).to eq(3)

            team = team.merge(period_personal_fouls: 1)
            expect(team.points).to eq(3)
            expect(team.period_personal_fouls).to eq(1)
          end
        end

        context "start of possession" do
          it "returns false" do
            expect(possession.visitor.next_foul_in_penalty?).to eq(false)
            expect(possession.home.next_foul_in_penalty?).to eq(false)
          end
        end

        context "3 fouls" do
          it "returns false" do
            next_possession = possession.merge(home: possession.home.merge(period_personal_fouls: 3))
            expect(next_possession.home.next_foul_in_penalty?).to eq(false)
          end
        end

        context "4 fouls" do
          it "returns true" do
            next_possession = possession.merge(home: possession.home.merge(period_personal_fouls: 4))
            expect(next_possession.home.next_foul_in_penalty?).to eq(true)
          end
        end

        context "5 fouls" do
          it "returns true" do
            next_possession = possession.merge(home: possession.home.merge(period_personal_fouls: 5))
            expect(next_possession.home.next_foul_in_penalty?).to eq(true)
          end
        end

        context "6 fouls" do
          it "returns true" do
            next_possession = possession.merge(home: possession.home.merge(period_personal_fouls: 6))
            expect(next_possession.home.next_foul_in_penalty?).to eq(true)
          end
        end
      end

      describe "#==" do
        it "considers key" do
          expect(Team.new(key: :home)).to eq(Team.new(key: :home))
          expect(Team.new(key: :visitor)).not_to eq(Team.new(key: :home))
        end
      end
    end
  end
end
