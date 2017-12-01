require "spec_helper"
require "play_by_play/model/game_play"
require "play_by_play/model/play"
require "play_by_play/model/possession"

module PlayByPlay
  module Model
    RSpec.describe Play do
      describe ":offensive_foul" do
        it "updates team, ball_in_play, and free throws" do
          possession = Possession.new(ball_in_play: true, team: :home)
          next_possession = GamePlay.play!(possession, [ :offensive_foul, player: 0, fouled: 0 ])
          expect(next_possession.ball_in_play?).to eq(false)
          expect(next_possession.team).to eq(:visitor)
          expect(next_possession.offense).to eq(:visitor)
          expect(next_possession.home.period_personal_fouls).to eq(0)
        end
      end

      describe ":offensive_foul during FTs" do
        it "cancels FTs" do
          possession = Possession.new(free_throws: [ :home, :home, :home ], next_team: :visitor, team: :home)
          next_possession = GamePlay.play!(possession, [ :offensive_foul, player: 0, fouled: 0 ])
          expect(next_possession.ball_in_play?).to eq(false)
          expect(next_possession.team).to eq(:visitor)
          expect(next_possession.offense).to eq(:visitor)
          expect(next_possession.free_throws).to eq([])
        end
      end

      describe ":offensive_foul during rebound" do
        it "updates team, ball_in_play, and free throws" do
          possession = Possession.new(ball_in_play: false, team: :visitor)
          next_possession = GamePlay.play!(possession, [ :offensive_foul, player: 0, fouled: 0 ])
          expect(next_possession.ball_in_play?).to eq(false)
          expect(next_possession.team).to eq(:home)
          expect(next_possession.offense).to eq(:home)
          expect(possession.free_throws).to eq([])
        end
      end

      describe ":shooting_foul" do
        it "gives the offense FTs" do
          possession = Possession.new(ball_in_play: true, team: :home)
          possession = GamePlay.play!(possession, [ :shooting_foul, player: 0, fouled: 0 ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.free_throws).to eq([ :home, :home ])
          expect(possession.team).to eq(:home)
          expect(possession.visitor.period_personal_fouls).to eq(1)
        end

        it "gives the offense 3 FTs for a 3PT attempt" do
          possession = Possession.new(ball_in_play: true, team: :home)
          possession = GamePlay.play!(possession, [ :shooting_foul, point_value: 3, player: 0, fouled: 0 ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.free_throws).to eq([ :home, :home, :home ])
          expect(possession.team).to eq(:home)
          expect(possession.visitor.period_personal_fouls).to eq(1)
        end
      end

      describe ":technical_foul" do
        it "gives other team a technical FT" do
          possession = Possession.new(ball_in_play: true, team: :home)
          possession = GamePlay.play!(possession, [ :technical_foul, team: :offense, player: 0, fouled: 0 ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.technical_free_throws).to eq([ :visitor ])
          expect(possession.offense).to eq(:visitor)
          expect(possession.team).to eq(:visitor)
          expect(possession.next_team).to eq(:home)
        end

        it "gives other team a technical FT" do
          possession = Possession.new(ball_in_play: true, team: :home)
          possession = GamePlay.play!(possession, [ :technical_foul, team: :defense, player: 0 ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.technical_free_throws).to eq([ :home ])
          expect(possession.offense).to eq(:home)
          expect(possession.team).to eq(:home)
          expect(possession.next_team).to eq(:home)
        end

        it "gives other team a technical FT" do
          possession = Possession.new(team: :home, free_throws: [ :visitor ], next_team: :visitor)
          possession = GamePlay.play!(possession, [ :technical_foul, team: :offense, player: 0, fouled: 0 ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.free_throws).to eq([ :visitor ])
          expect(possession.technical_free_throws).to eq([ :visitor ])
          expect(possession.offense).to eq(:visitor)
          expect(possession.team).to eq(:visitor)
          expect(possession.next_team).to eq(:visitor)
        end

        it "gives other team a technical FT" do
          possession = Possession.new(team: :home, technical_free_throws: [ :home ])
          possession = GamePlay.play!(possession, [ :technical_foul, team: :offense, player: 0, fouled: 0 ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.free_throws).to eq([])
          expect(possession.technical_free_throws).to eq([ :home, :visitor ])
          expect(possession.offense).to eq(:visitor)
          expect(possession.team).to eq(:visitor)
          expect(possession.next_team).to eq(nil)
        end

        it "gives other team a technical FT" do
          possession = Possession.new(team: :home)
          possession = GamePlay.play!(possession, [ :technical_foul, team: :offense, player: 0, fouled: 0 ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.technical_free_throws).to eq([ :visitor ])
          expect(possession.offense).to eq(:visitor)
          expect(possession.team).to eq(:visitor)
          expect(possession.next_team).to eq(:home)
        end

        it "no team, ball not in play leads to jump ball" do
          possession = Possession.new
          possession = GamePlay.play!(possession, [ :technical_foul, team: :visitor, player: 0, fouled: 0 ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.technical_free_throws).to eq([ :home ])
          expect(possession.next_team).to eq(nil)
          expect(possession.team).to eq(:home)
          expect(possession.offense).to eq(:home)
        end

        describe "flagrant" do
          it "gives two shots" do
            possession = Possession.new(ball_in_play: true, team: :home)
            possession = GamePlay.play!(possession, [ :technical_foul, flagrant: true, team: :defense, player: 0, fouled: 0 ])
            expect(possession.ball_in_play?).to eq(false)
            expect(possession.technical_free_throws).to eq([ :home, :home ])
            expect(possession.offense).to eq(:home)
            expect(possession.team).to eq(:home)
            expect(possession.next_team).to eq(:home)
          end

          it "gives two shots and possession" do
            possession = Possession.new(ball_in_play: true, team: :home)
            possession = GamePlay.play!(possession, [ :technical_foul, flagrant: true, team: :offense, player: 0, fouled: 0 ])
            expect(possession.ball_in_play?).to eq(false)
            expect(possession.technical_free_throws).to eq([ :visitor, :visitor ])
            expect(possession.offense).to eq(:visitor)
            expect(possession.team).to eq(:visitor)
            expect(possession.next_team).to eq(:visitor)
          end
        end
      end
    end
  end
end
