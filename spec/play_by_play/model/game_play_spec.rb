require "spec_helper"
require "play_by_play/model/game_play"
require "play_by_play/model/play"
require "play_by_play/model/possession"

module PlayByPlay
  module Model
    RSpec.describe GamePlay do
      describe "#play!" do
        it "creates a new Possession from a Play" do
          play = [ :jump_ball, team: :home, home_jump: 0, tip: 0, visitor_jump: 0 ]
          possession = Possession.new
          expect(GamePlay.play!(possession, play)).to_not eq(possession)
          expect(GamePlay.play!(possession, play)).to_not equal(possession)
          expect(possession.errors?).to eq(false)
        end

        it "raises errors for invalid play types" do
          possession = Possession.new(team: :visitor, technical_free_throws: [ :home ])
          expect { GamePlay.play!(possession, [ :fg, player: 0 ]) }.to raise_error(InvalidStateError)
        end

        it "accepts player: for :fg" do
          play = [ :fg, player: 5 ]
          possession = Possession.new(team: :home)
          next_possession = GamePlay.play!(possession, play)
          expect(next_possession.home.points).to eq(2)
        end

        it "raises errors for invalid player" do
          possession = Possession.new(team: :visitor)
          expect { GamePlay.play!(possession, [ :fg, player: 13 ]) }.to raise_error(ArgumentError)
        end

        it "applies :ft" do
          possession = Possession.new(team: :home, technical_free_throws: [ :home, :home ], home: Team.new(key: :home, points: 10))
          next_possession = GamePlay.play!(possession, [ :ft, player: 0 ])
          expect(next_possession.technical_free_throws).to eq([ :home ])
          expect(next_possession.home.points).to eq(11)
          expect(next_possession.errors?).to eq(false)
        end

        it "assigns correct team after dead ball technical foul" do
          possession = Possession.new(team: :visitor)

          possession = GamePlay.play!(possession, [ :technical_foul, team: :offense, foul: 5, fouled: 5 ])
          expect(possession.offense).to eq(:home)
          expect(possession.team).to eq(:home)
          expect(possession.next_team).to eq(:visitor)
          expect(possession.technical_free_throws).to eq([ :home ])

          possession = GamePlay.play!(possession, [ :ft_miss, player: 0 ])
          expect(possession.ball_in_play?).to eq(false)
          expect(possession.offense).to eq(:visitor)
          expect(possession.team).to eq(:visitor)
          expect(possession.technical_free_throws).to eq([])
        end

        it "assigns possession after multiple technicals" do
          possession = Possession.new(team: :home)

          possession = GamePlay.play!(possession, [ :technical_foul, team: :defense, flagrant: true, foul: 0, fouled: 0 ])
          expect(possession.technical_free_throws).to eq([ :home, :home ])
          expect(possession.offense).to eq(:home)
          expect(possession.team).to eq(:home)

          possession = GamePlay.play!(possession, [ :technical_foul, team: :offense, foul: 0, fouled: 0 ])
          expect(possession.offense).to eq(:visitor)
          expect(possession.team).to eq(:visitor)
          expect(possession.next_team).to eq(:home)
          expect(possession.technical_free_throws).to eq([ :home, :home, :visitor ])

          possession = GamePlay.play!(possession, [ :ft_miss, player: 0 ])
          expect(possession.offense).to eq(:home)
          expect(possession.team).to eq(:home)
          expect(possession.next_team).to eq(:home)
          expect(possession.technical_free_throws).to eq([ :home, :home ])

          possession = GamePlay.play!(possession, [ :ft, player: 0 ])
          expect(possession.technical_free_throws).to eq([ :home ])
          expect(possession.home.points).to eq(1)
          expect(possession.offense).to eq(:home)
          expect(possession.team).to eq(:home)
          expect(possession.next_team).to eq(:home)

          possession = GamePlay.play!(possession, [ :ft, player: 0 ])
          expect(possession.technical_free_throws).to eq([])
          expect(possession.home.points).to eq(2)
          expect(possession.offense).to eq(:home)
          expect(possession.team).to eq(:home)
          expect(possession.next_team).to eq(nil)
          expect(possession.ball_in_play?).to eq(false)
        end

        it "assigns possession after dead ball flagrant foul" do
          possession = Possession.new(team: :visitor, home: Team.new(key: :home, period_personal_fouls: 6))

          possession = GamePlay.play!(possession, [ :personal_foul, team: :defense, foul: 0, fouled: 0 ])
          expect(possession.offense).to eq(:visitor)
          expect(possession.team).to eq(:visitor)
          expect(possession.next_team).to eq(nil)
          expect(possession.free_throws).to eq([ :visitor, :visitor ])

          possession = GamePlay.play!(possession, [ :ft, player: 0 ])
          expect(possession.free_throws).to eq([ :visitor ])
          expect(possession.visitor.points).to eq(1)
          expect(possession.next_team).to eq(nil)

          possession = GamePlay.play!(possession, [ :ft, player: 0 ])
          expect(possession.free_throws).to eq([])
          expect(possession.visitor.points).to eq(2)
          expect(possession.offense).to eq(:home)
          expect(possession.team).to eq(:home)

          possession = GamePlay.play!(possession, [ :technical_foul, team: :defense, flagrant: true, foul: 0 ])
          expect(possession.offense).to eq(:home)
          expect(possession.team).to eq(:home)
          expect(possession.next_team).to eq(:home)
          expect(possession.technical_free_throws).to eq([ :home, :home ])

          possession = GamePlay.play!(possession, [ :ft, player: 0 ])
          expect(possession.technical_free_throws).to eq([ :home ])
          expect(possession.home.points).to eq(1)
          expect(possession.offense).to eq(:home)
          expect(possession.team).to eq(:home)
          expect(possession.next_team).to eq(:home)

          possession = GamePlay.play!(possession, [ :ft, player: 0 ])
          expect(possession.technical_free_throws).to eq([])
          expect(possession.home.points).to eq(2)
          expect(possession.offense).to eq(:home)
          expect(possession.team).to eq(:home)
          expect(possession.ball_in_play?).to eq(false)
        end

        it "assigns possession correctly on dead ball technical_foul" do
          possession = Possession.new(ball_in_play: false, team: :visitor)

          possession = GamePlay.play!(possession, [ :technical_foul, team: :offense, foul: 2, fouled: 1 ])
          expect(possession.technical_free_throws).to eq([ :home ])
          expect(possession.offense).to eq(:home)
          expect(possession.team).to eq(:home)
          expect(possession.next_team).to eq(:visitor)

          possession = GamePlay.play!(possession, [ :ft, player: 0 ])
          expect(possession.offense).to eq(:visitor)
          expect(possession.team).to eq(:visitor)
        end
      end

      describe "decrement_free_throws" do
        it "decrements free throw count by 1" do
          possession = Possession.new(team: :home, free_throws: [ :home, :home, :home ])
          expect(GamePlay.decrement_free_throws(possession)).to eq(free_throws: [ :home, :home ])

          possession = Possession.new(team: :home, free_throws: [ :home, :home ])
          expect(GamePlay.decrement_free_throws(possession)).to eq(free_throws: [ :home ])

          possession = Possession.new(team: :home, free_throws: [ :home ])
          expect(GamePlay.decrement_free_throws(possession)).to eq(free_throws: [])
        end

        it "decrements technical free throws first" do
          possession = Possession.new(team: :home, free_throws: [ :home, :home ], technical_free_throws: [ :home ])
          expect(GamePlay.decrement_free_throws(possession)).to eq(technical_free_throws: [])

          possession = Possession.new(team: :home, free_throws: [ :home, :home ], technical_free_throws: [])
          expect(GamePlay.decrement_free_throws(possession)).to eq(free_throws: [ :home ])
        end

        it "decrements technical technical free throws first" do
          possession = Possession.new(team: :home, technical_free_throws: [ :home, :home ])
          expect(GamePlay.decrement_free_throws(possession)).to eq(technical_free_throws: [ :home ])

          possession = Possession.new(team: :home, technical_free_throws: [ :home ])
          expect(GamePlay.decrement_free_throws(possession)).to eq(technical_free_throws: [])
        end
      end
    end
  end
end
