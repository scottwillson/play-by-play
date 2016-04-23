require "spec_helper"
require "play_by_play/model/game_play"
require "play_by_play/model/play"
require "play_by_play/model/possession"

module PlayByPlay
  module Model
    RSpec.describe Play do
      describe ".new" do
        it "creates a Play" do
          play = Play.new(:ft)
          expect(play.type).to eq(:ft)
        end

        it "validates" do
          expect { Play.new(:foobar) }.to raise_error(ArgumentError)
        end
      end

      describe "#key" do
        it "considers type and attributes" do
          play = Play.new(:fg)
          play_2 = Play.new(:fg)
          play_3 = Play.new(:fg, point_value: 3)
          play_4 = Play.new(:fg, point_value: 3)

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

      describe ":fg" do
        it "updates team and ball_in_play" do
          possession = Possession.new(ball_in_play: true, team: :home, home: { period_personal_fouls: 2 })
          expect(possession.home.period_personal_fouls).to eq(2)

          next_possession = GamePlay.play!(possession, [ :fg ])

          expect(next_possession.ball_in_play?).to eq(false)
          expect(next_possession.team).to eq(:visitor)
          expect(next_possession.home.points).to eq(2)
          expect(next_possession.home.period_personal_fouls).to eq(2)
        end
      end

      describe ":fg with attributes" do
        it "updates team, ball_in_play, and fouls" do
          possession = Possession.new(ball_in_play: true, team: :home)
          next_possession = GamePlay.play!(possession, [ :fg, point_value: 3, and_one: true, assisted: true ])
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
          next_possession = GamePlay.play!(possession, [ :fg, assisted: true, seconds: 21 ])
          expect(next_possession.visitor.points).to eq(2)
        end
      end

      describe ":fg_miss" do
        it "updates team and ball_in_play" do
          possession = Possession.new(ball_in_play: false, team: :visitor)
          possession = GamePlay.play!(possession, [ :fg_miss ])
          expect(possession.ball_in_play?).to eq(true)
          expect(possession.team).to eq(nil)
        end

        it "updates team and ball_in_play" do
          possession = Possession.new(ball_in_play: true, team: :home)
          possession = GamePlay.play!(possession, [ :fg_miss, point_value: 3 ])
          expect(possession.ball_in_play?).to eq(true)
          expect(possession.team).to eq(nil)
        end
      end

      describe ":ft" do
        it "updates team, ball_in_play, and free throws" do
          possession = Possession.new(team: :home, free_throws: [ :home ], next_team: :visitor)
          possession = GamePlay.play!(possession, [ :ft ])
          expect(possession.free_throws).to eq([])
          expect(possession.home.points).to eq(1)
          expect(possession.errors?).to eq(false)
          expect(possession.team).to eq(:visitor)
          expect(possession.next_team).to eq(nil)
          expect(possession.offense).to eq(:visitor)
        end

        it "decrements technical free throws" do
          possession = Possession.new(team: :home, technical_free_throws: [ :home ], next_team: :visitor)
          next_possession = GamePlay.play!(possession, [ :ft ])
          expect(next_possession.free_throws).to eq([])
          expect(next_possession.technical_free_throws).to eq([])
        end
      end

      describe ":ft_miss" do
        it "updates free throws" do
          possession = Possession.new(free_throws: [ :visitor, :visitor ], team: :visitor, next_team: :home)
          possession = GamePlay.play!(possession, [ :ft_miss ])
          expect(possession.free_throws).to eq([ :visitor ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.team).to eq(:visitor)
          expect(possession.next_team).to eq(:home)
          expect(possession.offense).to eq(:visitor)
        end

        it "updates team, ball_in_play, and free throws" do
          possession = Possession.new(free_throws: [ :visitor ], team: :visitor, next_team: :home)
          possession = GamePlay.play!(possession, [ :ft_miss ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.free_throws).to eq([])
          expect(possession.team).to eq(:home)
          expect(possession.next_team).to eq(nil)
          expect(possession.offense).to eq(:home)
        end

        it "decrements technical free throws" do
          possession = Possession.new(technical_free_throws: [ :visitor, :visitor ], team: :visitor, next_team: :home)
          possession = GamePlay.play!(possession, [ :ft_miss ])
          expect(possession.free_throws).to eq([])
          expect(possession.technical_free_throws).to eq([ :visitor ])
        end
      end

      describe ":jump_ball" do
        context "first jump ball" do
          it "assigns team" do
            possession = Possession.new
            next_possession = GamePlay.play!(possession, [ :jump_ball, team: :home ])
            expect(next_possession.ball_in_play?).to eq(true)
            expect(next_possession.team).to eq(:home)
            expect(next_possession.offense).to eq(:home)

            expect(next_possession.opening_tip).to eq(:home)
          end
        end

        context "later jump ball" do
          it "assigns team" do
            possession = Possession.new(opening_tip: :visitor)
            next_possession = GamePlay.play!(possession, [ :jump_ball, team: :home ])
            expect(next_possession.ball_in_play?).to eq(true)
            expect(next_possession.team).to eq(:home)
            expect(next_possession.offense).to eq(:home)
            expect(next_possession.opening_tip).to eq(:visitor)
          end
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

      describe ":offensive_foul" do
        it "updates team, ball_in_play, and free throws" do
          possession = Possession.new(ball_in_play: true, team: :home)
          next_possession = GamePlay.play!(possession, [ :offensive_foul ])
          expect(next_possession.ball_in_play?).to eq(false)
          expect(next_possession.team).to eq(:visitor)
          expect(next_possession.offense).to eq(:visitor)
          expect(next_possession.home.period_personal_fouls).to eq(0)
        end
      end

      describe ":offensive_foul during FTs" do
        it "cancels FTs" do
          possession = Possession.new(free_throws: [ :home, :home, :home ], next_team: :visitor, team: :home)
          next_possession = GamePlay.play!(possession, [ :offensive_foul ])
          expect(next_possession.ball_in_play?).to eq(false)
          expect(next_possession.team).to eq(:visitor)
          expect(next_possession.offense).to eq(:visitor)
          expect(next_possession.free_throws).to eq([])
        end
      end

      describe ":offensive_foul during rebound" do
        it "updates team, ball_in_play, and free throws" do
          possession = Possession.new(ball_in_play: false, team: :visitor)
          next_possession = GamePlay.play!(possession, [ :offensive_foul ])
          expect(next_possession.ball_in_play?).to eq(false)
          expect(next_possession.team).to eq(:home)
          expect(next_possession.offense).to eq(:home)
          expect(possession.free_throws).to eq([])
        end
      end

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
            possession = Possession.new(period: 4, opening_tip: :visitor, seconds_remaining: 0)

            possession = GamePlay.play!(possession, [ :period_end ])

            expect(possession.home.period_personal_fouls).to eq(0)
            expect(possession.visitor.period_personal_fouls).to eq(0)
            expect(possession.team).to be_nil
            expect(possession.period).to eq(5)
            expect(possession.seconds_remaining).to eq(300)
          end
        end
      end

      describe ":rebound" do
        it "assigns team and puts ball_in_play" do
          possession = Possession.new(ball_in_play: true, team: :home)
          possession = GamePlay.play!(possession, [ :fg_miss ])
          next_possession = GamePlay.play!(possession, [ :rebound, team: :offense ])
          expect(next_possession.ball_in_play?).to eq(true)
          expect(next_possession.team).to eq(:home)
          expect(next_possession.offense).to eq(:home)
        end
      end

      describe ":shooting_foul" do
        it "gives the offense FTs" do
          possession = Possession.new(ball_in_play: true, team: :home)
          possession = GamePlay.play!(possession, [ :shooting_foul ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.free_throws).to eq([ :home, :home ])
          expect(possession.team).to eq(:home)
          expect(possession.visitor.period_personal_fouls).to eq(1)
        end

        it "gives the offense 3 FTs for a 3PT attempt" do
          possession = Possession.new(ball_in_play: true, team: :home)
          possession = GamePlay.play!(possession, [ :shooting_foul, point_value: 3 ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.free_throws).to eq([ :home, :home, :home ])
          expect(possession.team).to eq(:home)
          expect(possession.visitor.period_personal_fouls).to eq(1)
        end
      end

      describe ":steal" do
        it "gives ball to other team" do
          possession = Possession.new(ball_in_play: true, team: :home)
          next_possession = GamePlay.play!(possession, [ :steal ])
          expect(next_possession.ball_in_play?).to eq(true)
          expect(next_possession.team).to eq(:visitor)
          expect(next_possession.offense).to eq(:visitor)
        end
      end

      describe ":team_rebound" do
        it "assigns team" do
          possession = Possession.new(ball_in_play: true, team: :visitor)
          possession = GamePlay.play!(possession, [ :fg_miss ])
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

      describe ":technical_foul" do
        it "gives other team a technical FT" do
          possession = Possession.new(ball_in_play: true, team: :home)
          possession = GamePlay.play!(possession, [ :technical_foul, team: :offense ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.technical_free_throws).to eq([ :visitor ])
          expect(possession.offense).to eq(:visitor)
          expect(possession.team).to eq(:visitor)
          expect(possession.next_team).to eq(:home)
        end

        it "gives other team a technical FT" do
          possession = Possession.new(ball_in_play: true, team: :home)
          possession = GamePlay.play!(possession, [ :technical_foul, team: :defense ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.technical_free_throws).to eq([ :home ])
          expect(possession.offense).to eq(:home)
          expect(possession.team).to eq(:home)
          expect(possession.next_team).to eq(:home)
        end

        it "gives other team a technical FT" do
          possession = Possession.new(team: :home, free_throws: [ :visitor ], next_team: :visitor)
          possession = GamePlay.play!(possession, [ :technical_foul, team: :offense ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.free_throws).to eq([ :visitor ])
          expect(possession.technical_free_throws).to eq([ :visitor ])
          expect(possession.offense).to eq(:visitor)
          expect(possession.team).to eq(:visitor)
          expect(possession.next_team).to eq(:visitor)
        end

        it "gives other team a technical FT" do
          possession = Possession.new(team: :home, technical_free_throws: [ :home ])
          possession = GamePlay.play!(possession, [ :technical_foul, team: :offense ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.free_throws).to eq([])
          expect(possession.technical_free_throws).to eq([ :home, :visitor ])
          expect(possession.offense).to eq(:visitor)
          expect(possession.team).to eq(:visitor)
          expect(possession.next_team).to eq(nil)
        end

        it "gives other team a technical FT" do
          possession = Possession.new(team: :home)
          possession = GamePlay.play!(possession, [ :technical_foul, team: :offense ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.technical_free_throws).to eq([ :visitor ])
          expect(possession.offense).to eq(:visitor)
          expect(possession.team).to eq(:visitor)
          expect(possession.next_team).to eq(:home)
        end

        it "no team, ball not in play leads to jump ball" do
          possession = Possession.new
          possession = GamePlay.play!(possession, [ :technical_foul, team: :visitor ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.technical_free_throws).to eq([ :home ])
          expect(possession.next_team).to eq(nil)
          expect(possession.team).to eq(:home)
          expect(possession.offense).to eq(:home)
        end

        describe "flagarant" do
          it "gives two shots" do
            possession = Possession.new(ball_in_play: true, team: :home)
            possession = GamePlay.play!(possession, [ :technical_foul, flagarant: true, team: :defense ])
            expect(possession.ball_in_play?).to eq(false)
            expect(possession.technical_free_throws).to eq([ :home, :home ])
            expect(possession.offense).to eq(:home)
            expect(possession.team).to eq(:home)
            expect(possession.next_team).to eq(:home)
          end

          it "gives two shots and possession" do
            possession = Possession.new(ball_in_play: true, team: :home)
            possession = GamePlay.play!(possession, [ :technical_foul, flagarant: true, team: :offense ])
            expect(possession.ball_in_play?).to eq(false)
            expect(possession.technical_free_throws).to eq([ :visitor, :visitor ])
            expect(possession.offense).to eq(:visitor)
            expect(possession.team).to eq(:visitor)
            expect(possession.next_team).to eq(:visitor)
          end
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
      end

      describe ":turnover" do
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
