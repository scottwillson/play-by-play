require "spec_helper"
require "play_by_play/model/possession"

module PlayByPlay
  module Model
    RSpec.describe Possession do
      it "is described by four boolean attributes" do
        possession = Possession.new
        expect(possession.ball_in_play?).to eq(false)
        expect(possession.free_throws?).to eq(false)
        expect(possession.team?).to eq(false)
        expect(possession.technical_free_throws?).to eq(false)
      end

      describe ".new" do
        it "creates a Possession with teams" do
          possession = Possession.new
          expect(possession.home).to eq(Team.new(key: :home, period_personal_fouls: 0, points: 0))
          expect(possession.visitor).to eq(Team.new(key: :visitor, period_personal_fouls: 0, points: 0))
        end

        it "validates state" do
          expect { Possession.new(ball_in_play: true, technical_free_throws: [ :home ]) }.to raise_error(InvalidStateError)
        end

        describe "@offense" do
          it "is set to team" do
            possession = Possession.new(team: :home)
            expect(possession.team).to eq(:home)
            expect(possession.offense).to eq(:home)
          end
        end

        describe "team argument" do
          it "can be a symbol" do
            possession = Possession.new(team: :visitor)
            expect(possession.team).to eq(:visitor)
          end
        end
      end

      describe ".merge" do
        it "it reuses instance if there are no changes" do
          possession = Possession.new(ball_in_play: true)
          copy = possession.merge

          expect(possession).to eq(copy)
          expect(possession).to equal(copy)

          expect(possession.teams).to eq(copy.teams)
          expect(possession.home).to equal(copy.home)
          expect(possession.visitor).to equal(copy.visitor)
        end

        it "merges attributes" do
          possession = Possession.new(ball_in_play: true, team: :home)
          copy = possession.merge(team: :visitor)

          expect(possession).not_to equal(copy)

          expect(copy.ball_in_play?).to eq(true)
          expect(copy.team?).to eq(true)
          expect(copy.team).to eq(:visitor)
        end

        it "preserves team" do
          possession = Possession.new(team: :visitor)
          copy = possession.merge
          expect(copy.team).to eq(:visitor)
        end
      end

      describe "#errors?" do
        it "checks errors" do
          expect(Possession.new.errors?).to eq(false)
        end
      end
    end
  end
end
