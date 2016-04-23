require "spec_helper"
require "json"
require "play_by_play/sample/game"

module PlayByPlay
  module Sample
    RSpec.describe Game do
      describe "#import" do
        it "saves plays from JSON file", database: true do
          repository = Repository.new
          repository.reset!

          file = Game.new("0021400001", "ORL", "NOP")
          file.import("spec/data", repository: repository)

          expect(repository.count_plays({}, [ :jump_ball, team: :home ])).to eq(1)
          expect(repository.count_plays({ team: true }, [ :fg ])).to eq(32)
          expect(file.error_eventnum).to be_nil
          expect(file.errors).to eq([])
          expect(file.id).to_not be_nil
          expect(file.rows.size).to eq(512)
        end
      end

      describe "#parse" do
        it "creates plays from JSON file" do
          json = JSON.parse(File.read("spec/data/0021400001.json"))
          file = Game.new("0021400001", "ORL", "NOP")
          possession = file.parse(json, ENV["DEBUG"])
          expect(possession).to_not be_nil
          expect(file.errors).to be_nil
          expect(possession.errors).to eq([])
          expect(possession.errors?).to eq(false)
          expect(file.error_eventnum).to be_nil
          expect(file.id).to be_nil

          expect(file.plays[0].possession.opening_tip).to eq(nil)
          expect(file.plays[0].possession.period).to eq(1)
          expect(file.plays[0].possession_key => file.plays[0].key).to eq({} => [ :jump_ball, team: :home ])
          expect(file.plays[0].possession.seconds_remaining).to eq(720)
          expect(file.plays[0].seconds).to eq(0)

          expect(file.plays[1].possession.opening_tip).to eq(:home)
          expect(file.plays[1].possession.period).to eq(1)
          expect(file.plays[1].possession.seconds_remaining).to eq(720)
          expect(file.plays[1].possession_key => file.plays[1].key).to eq({ team: true } => [ :fg_miss ])
          expect(file.plays[1].seconds).to eq(17)

          expect(file.plays[2].possession_key => file.plays[2].key).to eq({ ball_in_play: true } => [ :rebound, team: :defense ])

          play = file.find_play_by_eventnum!(14)
          expect(play.possession.team).to eq(:home)
          expect(play.possession_key => play.key).to eq({ free_throws: true } => [ :ft_miss ])
          expect(play.possession.visitor.points).to eq(2)
          expect(play.possession.home.points).to eq(1)

          play = file.find_play_by_eventnum!(50)
          expect(play.possession.visitor.points).to eq(9)
          expect(play.possession.home.points).to eq(11)

          play = file.find_play_by_eventnum!(56)
          expect(play.possession.visitor.points).to eq(11)
          expect(play.possession.home.points).to eq(11)

          play = file.find_play_by_eventnum!(62)
          expect(play.possession.visitor.points).to eq(13)
          expect(play.possession.home.points).to eq(14)

          play = file.find_play_by_eventnum!(63)
          expect(play.possession.visitor.points).to eq(13)
          expect(play.possession.home.points).to eq(14)
          expect(play.possession.team).to eq(:visitor)
          expect(play.possession.offense).to eq(:visitor)
          expect(play.possession_key => play.key).to eq({ team: true } => [ :fg ])

          play = file.find_play_by_eventnum!(67)
          expect(play.possession.visitor.points).to eq(15)
          expect(play.possession.home.points).to eq(14)

          play = file.find_play_by_eventnum!(74)
          expect(play.possession.visitor.points).to eq(17)
          expect(play.possession.home.points).to eq(14)

          play = file.find_play_by_eventnum!(76)
          expect(play.possession.visitor.points).to eq(18)
          expect(play.possession.home.points).to eq(14)

          play = file.find_play_by_eventnum!(156)
          expect(play.possession.team).to eq(nil)
          expect(play.possession.seconds_remaining).to eq(25)
          expect(play.possession.offense).to eq(:visitor)
          expect(play.possession_key => play.key).to eq({ ball_in_play: true } => [ :rebound, team: :offense ])
          expect(play.possession.visitor.points).to eq(25)
          expect(play.possession.home.points).to eq(22)

          play = file.find_play_by_eventnum!(157)
          expect(play.possession.team).to eq(:visitor)
          expect(play.possession_key => play.key).to eq({ team: true } => [ :steal ])
          expect(play.possession.seconds_remaining).to eq(24)
          expect(play.possession.period).to eq(1)

          play = file.find_play_by_eventnum!(159)
          expect(play.possession.team).to eq(:home)
          expect(play.possession.period).to eq(1)
          expect(play.possession.seconds_remaining).to eq(21)
          expect(play.seconds).to eq(21)

          play = file.find_play_by_eventnum!(164)
          expect(play.possession.home.period_personal_fouls).to eq(0)
          expect(play.possession.visitor.period_personal_fouls).to eq(0)
          expect(play.possession.period).to eq(2)
          expect(play.possession.team).to eq(:visitor)
          expect(play.possession.seconds_remaining).to eq(720)

          play = file.find_play_by_eventnum!(178)
          expect(play.possession.team).to eq(:visitor)
          expect(play.possession_key => play.key).to eq({ team: true } => [ :turnover ])

          play = file.find_play_by_eventnum!(179)
          expect(play.possession.team).to eq(:home)
          expect(play.possession.home.period_personal_fouls).to eq(0)
          expect(play.possession.visitor.period_personal_fouls).to eq(0)
          expect(play.possession_key => play.key).to eq({ team: true } => [ :shooting_foul ])

          play = file.find_play_by_eventnum!(180)
          expect(play.possession.home.period_personal_fouls).to eq(0)
          expect(play.possession.visitor.period_personal_fouls).to eq(1)

          play = file.find_play_by_eventnum!(187)
          expect(play.possession.home.period_personal_fouls).to eq(0)
          expect(play.possession_key => play.key).to eq({ team: true } => [ :fg ])

          play = file.find_play_by_eventnum!(189)
          expect(play.possession.home.period_personal_fouls).to eq(1)
          expect(play.possession_key => play.key).to eq({ free_throws: true } => [ :ft ])

          play = file.find_play_by_eventnum!(218)
          expect(play.possession.home.period_personal_fouls).to eq(1)
          expect(play.possession_key => play.key).to eq({ team: true } => [ :fg, and_one: true, assisted: true ])

          play = file.find_play_by_eventnum!(346)
          expect(play.possession_key => play.key).to eq({ team: true } => [ :fg, point_value: 3, assisted: true ])

          play = file.find_play_by_eventnum!(556)
          expect(play.possession.home.period_personal_fouls).to eq(2)

          play = file.find_play_by_eventnum!(568)
          expect(play.possession.period).to eq(4)
          expect(play.possession.home.period_personal_fouls).to eq(2)

          play = file.find_play_by_eventnum!(575)
          expect(play.possession.period).to eq(4)
          expect(play.possession.home.period_personal_fouls).to eq(3)

          expected = {
            visitor: {
              points: 84
            },
            home: {
              points: 101
            }
          }

          actual = {
            visitor: {
              points: possession.visitor.points
            },
            home: {
              points: possession.home.points
            }
          }

          expect(actual).to eq(expected)

          expect(file.plays.size).to eq(426)
          expect(file.rows.size).to eq(512)
        end
      end
    end
  end
end
