require "spec_helper"
require "play_by_play/model/game_play"

module PlayByPlay
  module Model
    module GamePlay
      RSpec.describe "#period_end" do
        describe ":period_end" do
          it "ends period" do
            possession = Possession.new(opening_tip: :home, period: 3, seconds_remaining: 0, visitor: { period_personal_fouls: 1 })

            possession = GamePlay.play!(possession, [ :period_end ])

            expect(possession.home.period_personal_fouls).to eq(0)
            expect(possession.visitor.period_personal_fouls).to eq(0)
            expect(possession.team).to eq(:home)
            expect(possession.period).to eq(4)
            expect(possession.seconds_remaining).to eq(720)
          end

          it "ends period and resets seconds_remaining" do
            possession = Possession.new(opening_tip: :home, period: 3, seconds_remaining: 10, visitor: { period_personal_fouls: 1 })

            possession = GamePlay.play!(possession, [ :period_end, seconds: 10 ])

            expect(possession.home.period_personal_fouls).to eq(0)
            expect(possession.visitor.period_personal_fouls).to eq(0)
            expect(possession.team).to eq(:home)
            expect(possession.period).to eq(4)
            expect(possession.seconds_remaining).to eq(720)
          end

          context "start of possession" do
            it "is invalid" do
              possession = Possession.new
              expect { GamePlay.play!(possession, [ :period_end ]) }.to raise_error(InvalidStateError)
            end
          end

          context "middle of period" do
            it "is invalid" do
              possession = Possession.new(period: 2, seconds_remaining: 400)
              expect { GamePlay.play!(possession, [ :period_end ]) }.to raise_error(InvalidStateError)
            end
          end

          context "end of period 1" do
            it "assigns team to loser of opening tip" do
              possession = Possession.new(period: 1, opening_tip: :visitor, seconds_remaining: 0)

              possession = GamePlay.play!(possession, [ :period_end ])

              expect(possession.home.period_personal_fouls).to eq(0)
              expect(possession.visitor.period_personal_fouls).to eq(0)
              expect(possession.team).to eq(:home)
              expect(possession.period).to eq(2)
              expect(possession.seconds_remaining).to eq(720)
            end
          end

          context "end of period 2" do
            it "assigns team to loser of opening tip" do
              possession = Possession.new(period: 2, opening_tip: :visitor, seconds_remaining: 0)

              possession = GamePlay.play!(possession, [ :period_end ])

              expect(possession.home.period_personal_fouls).to eq(0)
              expect(possession.visitor.period_personal_fouls).to eq(0)
              expect(possession.team).to eq(:home)
              expect(possession.period).to eq(3)
              expect(possession.seconds_remaining).to eq(720)
            end
          end

          context "end of period 3" do
            it "assigns team to winner of opening tip" do
              possession = Possession.new(period: 3, opening_tip: :visitor, seconds_remaining: 0)

              possession = GamePlay.play!(possession, [ :period_end ])

              expect(possession.home.period_personal_fouls).to eq(0)
              expect(possession.visitor.period_personal_fouls).to eq(0)
              expect(possession.team).to eq(:visitor)
              expect(possession.period).to eq(4)
              expect(possession.seconds_remaining).to eq(720)
            end
          end

          context "end of period 4" do
            it "assigns no team" do
              possession = Possession.new(period: 4, opening_tip: :visitor, seconds_remaining: 0, visitor: { points: 9 })

              possession = GamePlay.play!(possession, [ :period_end ])

              expect(possession.home.period_personal_fouls).to eq(0)
              expect(possession.visitor.period_personal_fouls).to eq(0)
              expect(possession.team).to be_nil
              expect(possession.period).to eq(4)
              expect(possession.seconds_remaining).to eq(0)
            end
          end

          context "end of period 4 score tied (overtime)" do
            it "jump ball: assigns no team" do
              possession = Possession.new(period: 4, opening_tip: :visitor, seconds_remaining: 0, team: :home, offense: :home)

              possession = GamePlay.play!(possession, [ :period_end ])

              expect(possession.home.period_personal_fouls).to eq(0)
              expect(possession.visitor.period_personal_fouls).to eq(0)
              expect(possession.offense).to be_nil
              expect(possession.team).to be_nil
              expect(possession.period).to eq(5)
              expect(possession.seconds_remaining).to eq(300)
            end
          end
        end
      end
    end
  end
end
