require "spec_helper"
require "play_by_play/model/game_play"
require "play_by_play/model/play"
require "play_by_play/model/possession"

module PlayByPlay
  module Model
    module GamePlay
      RSpec.describe "#personal_foul" do
        describe "#personal_foul_in_last_two_minutes" do
          it "is set in last two minutes" do
            possession = Possession.new(ball_in_play: true, team: :home, seconds_remaining: 12)
            possession = GamePlay.play!(possession, [ :personal_foul, team: :defense ])
            expect(possession.visitor.personal_foul_in_last_two_minutes).to eq(true)
          end
        end

        describe ":personal_foul" do
          it "maintains possession and puts ball not in play" do
            possession = Possession.new(ball_in_play: true, team: :home)
            possession = GamePlay.play!(possession, [ :personal_foul, team: :defense ])
            expect(possession.ball_in_play?).to eq(false)
            expect(possession.next_team).to eq(nil)
            expect(possession.offense).to eq(:home)
            expect(possession.team).to eq(:home)
            expect(possession.free_throws).to eq([])
            expect(possession.visitor.period_personal_fouls).to eq(1)
            expect(possession.visitor.personal_foul_in_last_two_minutes).to eq(false)
          end

          it "assigns FTs if in penalty" do
            possession = Possession.new(ball_in_play: true, team: :home, visitor: { period_personal_fouls: 4 })
            possession = GamePlay.play!(possession, [ :personal_foul, team: :defense ])
            expect(possession.free_throws).to eq([ :home, :home ])
            expect(possession.ball_in_play?).to eq(false)
            expect(possession.next_team).to eq(nil)
            expect(possession.offense).to eq(:home)
            expect(possession.team).to eq(:home)
            expect(possession.visitor.period_personal_fouls).to eq(5)
          end

          it "does not assigns FT if not in penalty in last two minutes" do
            possession = Possession.new(ball_in_play: true, team: :home, visitor: { period_personal_fouls: 3, personal_foul_in_last_two_minutes: false }, seconds_remaining: 119)
            possession = GamePlay.play!(possession, [ :personal_foul, team: :defense ])
            expect(possession.free_throws).to eq([])
            expect(possession.ball_in_play?).to eq(false)
            expect(possession.next_team).to eq(nil)
            expect(possession.offense).to eq(:home)
            expect(possession.team).to eq(:home)
            expect(possession.visitor.period_personal_fouls).to eq(4)
          end

          it "assigns FTs if in penalty in last two minutes" do
            possession = Possession.new(ball_in_play: true, team: :home, visitor: { period_personal_fouls: 3, personal_foul_in_last_two_minutes: true }, seconds_remaining: 119)
            possession = GamePlay.play!(possession, [ :personal_foul, team: :defense ])
            expect(possession.free_throws).to eq([ :home, :home ])
            expect(possession.ball_in_play?).to eq(false)
            expect(possession.next_team).to eq(nil)
            expect(possession.offense).to eq(:home)
            expect(possession.team).to eq(:home)
            expect(possession.visitor.period_personal_fouls).to eq(4)
          end

          it "assigns FTs if in penalty in last two minutes" do
            possession = Possession.new(ball_in_play: true, team: :home, visitor: { period_personal_fouls: 7, personal_foul_in_last_two_minutes: false }, seconds_remaining: 119)
            possession = GamePlay.play!(possession, [ :personal_foul, team: :defense ])
            expect(possession.free_throws).to eq([ :home, :home ])
            expect(possession.ball_in_play?).to eq(false)
            expect(possession.next_team).to eq(nil)
            expect(possession.offense).to eq(:home)
            expect(possession.team).to eq(:home)
            expect(possession.visitor.period_personal_fouls).to eq(8)
          end

          it "assigns FTs if in penalty in last two minutes" do
            possession = Possession.new(
              ball_in_play: true,
              team: :home,
              visitor: { period_personal_fouls: 7, personal_foul_in_last_two_minutes: true },
              seconds_remaining: 119
            )
            possession = GamePlay.play!(possession, [ :personal_foul, team: :defense ])
            expect(possession.free_throws).to eq([ :home, :home ])
            expect(possession.ball_in_play?).to eq(false)
            expect(possession.next_team).to eq(nil)
            expect(possession.offense).to eq(:home)
            expect(possession.team).to eq(:home)
            expect(possession.visitor.period_personal_fouls).to eq(8)
          end
        end

        describe ":personal_foul during free_throws" do
          it "maintains free_throws" do
            possession = Possession.new(free_throws: [ :home ], team: :home, next_team: :visitor)
            possession = GamePlay.play!(possession, [ :personal_foul, team: :defense ])
            expect(possession.ball_in_play?).to eq(false)
            expect(possession.team).to eq(:home)
            expect(possession.next_team).to eq(:visitor)
            expect(possession.offense).to eq(:home)
            expect(possession.free_throws).to eq([ :home ])
          end
        end

        describe ":personal_foul during rebound" do
          it "gives possession" do
            possession = Possession.new(ball_in_play: true, offense: :visitor)
            possession = GamePlay.play!(possession, [ :personal_foul, team: :defense ])
            expect(possession.ball_in_play?).to eq(false)
            expect(possession.team).to eq(:visitor)
            expect(possession.free_throws).to eq([])
            expect(possession.next_team).to eq(nil)
          end
        end

        describe ":personal_foul by offense away from ball" do
          it "gives possession" do
            possession = Possession.new(ball_in_play: true, offense: :visitor)
            possession = GamePlay.play!(possession, [ :personal_foul, team: :offense ])
            expect(possession.ball_in_play?).to eq(false)
            expect(possession.team).to eq(:home)
            expect(possession.free_throws).to eq([ :home ])
            expect(possession.next_team).to eq(nil)
          end
        end

        describe ":personal_foul by defense away from ball" do
          it "retains possession" do
            possession = Possession.new(ball_in_play: true, offense: :visitor)
            possession = GamePlay.play!(possession, [ :personal_foul, team: :defense ])
            expect(possession.ball_in_play?).to eq(false)
            expect(possession.team).to eq(:visitor)
            expect(possession.free_throws).to eq([])
            expect(possession.next_team).to eq(nil)
          end
        end

        describe "next_foul_in_penalty?" do
          let(:possession) { Possession.new }

          context "start of possession" do
            it "returns false" do
              expect(GamePlay.next_foul_in_penalty?(possession, possession.visitor)).to eq(false)
              expect(GamePlay.next_foul_in_penalty?(possession, possession.home)).to eq(false)
            end
          end

          context "3 fouls" do
            it "returns false" do
              next_possession = possession.merge(home: possession.home.merge(period_personal_fouls: 3))
              expect(GamePlay.next_foul_in_penalty?(next_possession, next_possession.home)).to eq(false)
            end
          end

          context "4 fouls" do
            it "returns true" do
              next_possession = possession.merge(home: possession.home.merge(period_personal_fouls: 4))
              expect(GamePlay.next_foul_in_penalty?(next_possession, next_possession.home)).to eq(true)
            end
          end

          context "5 fouls" do
            it "returns true" do
              next_possession = possession.merge(home: possession.home.merge(period_personal_fouls: 5))
              expect(GamePlay.next_foul_in_penalty?(next_possession, next_possession.home)).to eq(true)
            end
          end

          context "6 fouls" do
            it "returns true" do
              next_possession = possession.merge(home: possession.home.merge(period_personal_fouls: 6))
              expect(GamePlay.next_foul_in_penalty?(next_possession, next_possession.home)).to eq(true)
            end
          end
        end
      end
    end
  end
end
