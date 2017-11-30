require "spec_helper"
require "play_by_play/model/game_play"
require "play_by_play/model/play"
require "play_by_play/model/possession"

module PlayByPlay
  module Model
    RSpec.describe Play do
      describe ".new" do
        it "creates a Play" do
          play = Play.new(:ft, shot: 4)
          expect(play.type).to eq(:ft)
        end

        it "validates" do
          expect { Play.new(:foobar) }.to raise_error(ArgumentError)
        end
      end

      describe "#key" do
        it "considers type and attributes" do
          play = Play.new(:fg, shot: 0)
          play_2 = Play.new(:fg, shot: 0)
          play_3 = Play.new(:fg, point_value: 3, shot: 0)
          play_4 = Play.new(:fg, point_value: 3, shot: 0)

          expect(play.key).to eq(play_2.key)
          expect(play.key).to_not eq(play_3.key)
          expect(play.key).to_not eq(play_4.key)
          expect(play_3.key).to eq(play_4.key)
        end
      end

      describe ":block" do
        it "removes team" do
          possession = Possession.new(ball_in_play: true, team: :home)
          next_possession = GamePlay.play!(possession, [ :block ])
          expect(next_possession.ball_in_play?).to eq(true)
          expect(next_possession.team).to eq(nil)
          expect(next_possession.offense).to eq(:home)
        end

        it "accepts point_value" do
          possession = Possession.new(ball_in_play: true, team: :home)
          next_possession = GamePlay.play!(possession, [ :block, point_value: 3 ])
          expect(next_possession.ball_in_play?).to eq(true)
          expect(next_possession.team).to eq(nil)
          expect(next_possession.offense).to eq(:home)
        end

        it "sets ball_in_play" do
          possession = Possession.new(ball_in_play: false, team: :home)
          next_possession = GamePlay.play!(possession, [ :block, point_value: 3 ])
          expect(next_possession.ball_in_play?).to eq(true)
          expect(next_possession.team).to eq(nil)
          expect(next_possession.offense).to eq(:home)
        end
      end

      describe ":fg" do
        it "updates team and ball_in_play" do
          possession = Possession.new(ball_in_play: true, team: :home, home: { period_personal_fouls: 2 })
          expect(possession.home.period_personal_fouls).to eq(2)

          next_possession = GamePlay.play!(possession, [ :fg, shot: 0 ])

          expect(next_possession.ball_in_play?).to eq(false)
          expect(next_possession.team).to eq(:visitor)
          expect(next_possession.home.points).to eq(2)
          expect(next_possession.home.period_personal_fouls).to eq(2)
        end
      end

      describe ":fg with attributes" do
        it "updates team, ball_in_play, and fouls" do
          possession = Possession.new(ball_in_play: true, team: :home)
          next_possession = GamePlay.play!(possession, [ :fg, point_value: 3, assist: 1, shot: 0, and_one: true, assisted: true ])
          expect(next_possession.ball_in_play?).to eq(false)
          expect(next_possession.team).to eq(:home)
          expect(next_possession.next_team).to eq(nil)
          expect(next_possession.free_throws).to eq([ :home ])
          expect(next_possession.visitor.period_personal_fouls).to eq(1)
          expect(next_possession.home.points).to eq(3)
        end
      end

      describe ":fg at end of period" do
        it "updates points" do
          possession = Possession.new(ball_in_play: true, team: :visitor, seconds_remaining: 21)
          next_possession = GamePlay.play!(possession, [ :fg, assisted: true, assist: 3, seconds: 21, shot: 0 ])
          expect(next_possession.visitor.points).to eq(2)
        end
      end

      describe ":fg_miss" do
        it "updates team and ball_in_play" do
          possession = Possession.new(ball_in_play: false, team: :visitor)
          possession = GamePlay.play!(possession, [ :fg_miss, shot: 0 ])
          expect(possession.ball_in_play?).to eq(true)
          expect(possession.team).to eq(nil)
        end

        it "updates team and ball_in_play" do
          possession = Possession.new(ball_in_play: true, team: :home)
          possession = GamePlay.play!(possession, [ :fg_miss, point_value: 3, shot: 3 ])
          expect(possession.ball_in_play?).to eq(true)
          expect(possession.team).to eq(nil)
        end
      end

      describe ":ft_miss" do
        it "updates free throws" do
          possession = Possession.new(free_throws: [ :visitor, :visitor ], team: :visitor, next_team: :home)
          possession = GamePlay.play!(possession, [ :ft_miss, shot: 0 ])
          expect(possession.free_throws).to eq([ :visitor ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.team).to eq(:visitor)
          expect(possession.next_team).to eq(:home)
          expect(possession.offense).to eq(:visitor)
        end

        it "updates team, ball_in_play, and free throws" do
          possession = Possession.new(free_throws: [ :visitor ], team: :visitor, next_team: :home)
          possession = GamePlay.play!(possession, [ :ft_miss, shot: 0 ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.free_throws).to eq([])
          expect(possession.team).to eq(:home)
          expect(possession.next_team).to eq(nil)
          expect(possession.offense).to eq(:home)
        end

        it "decrements technical free throws" do
          possession = Possession.new(technical_free_throws: [ :visitor, :visitor ], team: :visitor, next_team: :home)
          possession = GamePlay.play!(possession, [ :ft_miss, shot: 0 ])
          expect(possession.free_throws).to eq([])
          expect(possession.technical_free_throws).to eq([ :visitor ])
        end
      end

      describe ":jump_ball_out_of_bounds" do
        it "assigns team" do
          possession = Possession.new
          next_possession = GamePlay.play!(possession, [ :jump_ball_out_of_bounds, team: :visitor ])
          expect(next_possession.ball_in_play?).to eq(false)
          expect(next_possession.team).to eq(:visitor)
          expect(next_possession.offense).to eq(:visitor)
        end
      end

      describe ":rebound" do
        it "assigns team and puts ball_in_play" do
          possession = Possession.new(ball_in_play: true, team: :home)
          possession = GamePlay.play!(possession, [ :fg_miss, shot: 0 ])
          next_possession = GamePlay.play!(possession, [ :rebound, team: :offense, rebound: 0 ])
          expect(next_possession.ball_in_play?).to eq(true)
          expect(next_possession.team).to eq(:home)
          expect(next_possession.offense).to eq(:home)
        end
      end

      describe ":steal" do
        it "gives ball to other team" do
          possession = Possession.new(ball_in_play: true, team: :home)
          next_possession = GamePlay.play!(possession, [ :steal, steal: 0, turnover: 0 ])
          expect(next_possession.ball_in_play?).to eq(true)
          expect(next_possession.team).to eq(:visitor)
          expect(next_possession.offense).to eq(:visitor)
        end
      end

      describe ":team_rebound" do
        it "assigns team" do
          possession = Possession.new(ball_in_play: true, team: :visitor)
          possession = GamePlay.play!(possession, [ :fg_miss, shot: 0 ])
          next_possession = GamePlay.play!(possession, [ :team_rebound, team: :defense ])
          expect(next_possession.ball_in_play?).to eq(true)
          expect(next_possession.team).to eq(:home)
          expect(next_possession.offense).to eq(:home)
        end

        it "assigns team after dead ball" do
          possession = Possession.new
          next_possession = GamePlay.play!(possession, [ :team_rebound, team: :visitor ])
          expect(next_possession.ball_in_play?).to eq(false)
          expect(next_possession.team).to eq(:visitor)
          expect(next_possession.offense).to eq(:visitor)
        end
      end

      describe ":turnover" do
        it "cancels FTs and gives ball to team" do
          possession = Possession.new(free_throws: [ :visitor, :visitor ], team: :visitor, next_team: :home)
          possession = GamePlay.play!(possession, [ :turnover ])
          expect(possession.free_throws).to eq([])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.team).to eq(:home)
        end

        it "gives ball to other team" do
          possession = Possession.new(ball_in_play: true, team: :visitor)
          expect(possession.team).to eq(:visitor)
          possession = GamePlay.play!(possession, [ :turnover ])
          expect(possession.free_throws).to eq([])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.team).to eq(:home)
        end
      end
    end
  end
end
