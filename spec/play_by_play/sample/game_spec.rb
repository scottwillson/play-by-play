require "spec_helper"
require "json"
require "play_by_play/model/possession"
require "play_by_play/sample/game"
require "play_by_play/sample/season"

module PlayByPlay
  module Sample
    RSpec.describe Game do
      describe "#import" do
        it "saves plays from JSON file", database: true do
          repository = Repository.new
          repository.reset!

          game = Game.new_game("0021400001", "ORL", "NOP")
          game = Game.import(game, "spec/data", repository: repository)
          season = Sample::Season.new_persistent
          day = Persistent::Day.new(season: season)
          game.day = day
          repository.seasons.save season

          expect(game.errors).to eq([])
          expect(game.error_eventnum).to be_nil

          expect(repository.plays.count(nil, :home, game.home_id, :home, [ :jump_ball, team: :home ])).to eq(1)
          expect(repository.plays.count(nil, :visitor, game.visitor_id, :visitor, [ :jump_ball, team: :home ])).to eq(1)

          expect(repository.plays.count(:team, :offense, game.visitor_id, :visitor, [ :block ])).to eq(16)
          expect(repository.plays.count(:team, :defense, game.home_id, :home, [ :block ])).to eq(16)
          expect(repository.plays.count(:team, :offense, game.visitor_id, :visitor, [ :block, point_value: 3 ])).to eq(1)
          expect(repository.plays.count(:team, :defense, game.home_id, :home, [ :block, point_value: 3 ])).to eq(1)
          expect(repository.plays.count(:team, :offense, game.visitor_id, :visitor, [ :fg ])).to eq(13)
          expect(repository.plays.count(:team, :defense, game.home_id, :home, [ :fg ])).to eq(13)
          expect(repository.plays.count(:team, :offense, game.visitor_id, :visitor, [ :fg, and_one: true ])).to eq(1)
          expect(repository.plays.count(:team, :defense, game.home_id, :home, [ :fg, and_one: true ])).to eq(1)
          expect(repository.plays.count(:team, :offense, game.visitor_id, :visitor, [ :fg, assisted: true ])).to eq(12)
          expect(repository.plays.count(:team, :defense, game.home_id, :home, [ :fg, assisted: true ])).to eq(12)
          expect(repository.plays.count(:team, :offense, game.visitor_id, :visitor, [ :fg, and_one: true, assisted: true ])).to eq(2)
          expect(repository.plays.count(:team, :defense, game.home_id, :home, [ :fg, and_one: true, assisted: true ])).to eq(2)
          expect(repository.plays.count(:team, :offense, game.visitor_id, :visitor, [ :fg, point_value: 3 ])).to eq(1)
          expect(repository.plays.count(:team, :defense, game.home_id, :home, [ :fg, point_value: 3 ])).to eq(1)
          expect(repository.plays.count(:team, :offense, game.visitor_id, :visitor, [ :fg, point_value: 3, and_one: true ])).to eq(0)
          expect(repository.plays.count(:team, :defense, game.home_id, :home, [ :fg, point_value: 3, and_one: true ])).to eq(0)
          expect(repository.plays.count(:team, :offense, game.visitor_id, :visitor, [ :fg, point_value: 3, and_one: true, assisted: true ])).to eq(0)
          expect(repository.plays.count(:team, :defense, game.home_id, :home, [ :fg, point_value: 3, and_one: true, assisted: true ])).to eq(0)
          expect(repository.plays.count(:team, :offense, game.visitor_id, :visitor, [ :fg, point_value: 3, assisted: true ])).to eq(3)
          expect(repository.plays.count(:team, :defense, game.home_id, :home, [ :fg, point_value: 3, assisted: true ])).to eq(3)
          expect(repository.plays.count(:team, :offense, game.visitor_id, :visitor, [ :fg_miss ])).to eq(29)
          expect(repository.plays.count(:team, :defense, game.home_id, :home, [ :fg_miss ])).to eq(29)
          expect(repository.plays.count(:team, :offense, game.visitor_id, :visitor, [ :fg_miss, point_value: 3 ])).to eq(6)
          expect(repository.plays.count(:team, :defense, game.home_id, :home, [ :fg_miss, point_value: 3 ])).to eq(6)

          expect(repository.plays.count(:team, :offense, game.home_id, :home, [ :block ])).to eq(9)
          expect(repository.plays.count(:team, :defense, game.visitor_id, :visitor, [ :block ])).to eq(9)
          expect(repository.plays.count(:team, :offense, game.home_id, :home, [ :block, point_value: 3 ])).to eq(0)
          expect(repository.plays.count(:team, :defense, game.visitor_id, :visitor, [ :block, point_value: 3 ])).to eq(0)
          expect(repository.plays.count(:team, :offense, game.home_id, :home, [ :fg ])).to eq(19)
          expect(repository.plays.count(:team, :defense, game.visitor_id, :visitor, [ :fg ])).to eq(19)
          expect(repository.plays.count(:team, :offense, game.home_id, :home, [ :fg_miss ])).to eq(38)
          expect(repository.plays.count(:team, :defense, game.visitor_id, :visitor, [ :fg_miss ])).to eq(38)
          expect(repository.plays.count(:team, :offense, game.home_id, :home, [ :fg_miss, point_value: 3 ])).to eq(13)
          expect(repository.plays.count(:team, :defense, game.visitor_id, :visitor, [ :fg_miss, point_value: 3 ])).to eq(13)

          expect(game.id).to_not be_nil
          expect(game.nba_id).to eq("0021400001")
          expect(game.rows.size).to eq(512)

          expect(repository.games.possessions(game.id).size).to eq(426)
          expect(repository.games.plays(game.id).size).to eq(425)

          play = plays.first
          expect(play.type).to eq(:jump_ball)
          expect(play).to be_kind_of(Persistent::Play)
          expect(play.player.name).to eq("Jrue Holiday")
          expect(play.player.nba_id).to eq(201_950)
        end
      end

      describe "#parse" do
        it "creates plays from JSON file" do
          json = JSON.parse(File.read("spec/data/0021400001.json"))
          game = Persistent::Game.new # ("0021400001") #, "ORL", "NOP"
          game = Game.parse(game, json)
          expect(game).to_not be_nil
          expect(game.errors).to eq([])
          expect(game.possession.errors?).to eq(false)
          expect(game.error_eventnum).to be_nil
          expect(game.id).to be_nil
          expect(game.home.players.size).to eq(12)
          expect(game.visitor.players.size).to eq(11)

          expect(game.plays[0].possession.opening_tip).to eq(nil)
          expect(game.plays[0].possession.period).to eq(1)
          expect(game.plays[0].possession_key => game.plays[0].key).to eq(nil => [ :jump_ball, team: :home ])
          expect(game.plays[0].possession.seconds_remaining).to eq(720)
          expect(game.plays[0].seconds).to eq(0)

          expect(game.plays[1].possession.opening_tip).to eq(:home)
          expect(game.plays[1].possession.period).to eq(1)
          expect(game.plays[1].possession.seconds_remaining).to eq(720)
          expect(game.plays[1].possession_key => game.plays[1].key).to eq(team: [ :fg_miss ])
          expect(game.plays[1].seconds).to eq(17)

          expect(game.plays[2].possession_key => game.plays[2].key).to eq(ball_in_play: [ :rebound, team: :defense ])

          play = Game.find_play_by_eventnum!(game, 14)
          expect(play.possession.team).to eq(:home)
          expect(play.possession_key => play.key).to eq(free_throws: [ :ft_miss ])
          expect(play.possession.visitor.points).to eq(2)
          expect(play.possession.home.points).to eq(1)

          play = Game.find_play_by_eventnum!(game, 50)
          expect(play.possession.visitor.points).to eq(9)
          expect(play.possession.home.points).to eq(11)

          play = Game.find_play_by_eventnum!(game, 56)
          expect(play.possession.visitor.points).to eq(11)
          expect(play.possession.home.points).to eq(11)

          play = Game.find_play_by_eventnum!(game, 62)
          expect(play.possession.visitor.points).to eq(13)
          expect(play.possession.home.points).to eq(14)

          play = Game.find_play_by_eventnum!(game, 63)
          expect(play.possession.visitor.points).to eq(13)
          expect(play.possession.home.points).to eq(14)
          expect(play.possession.team).to eq(:visitor)
          expect(play.possession.offense).to eq(:visitor)
          expect(play.possession_key => play.key).to eq(team: [ :fg ])
          expect(play.possession.play.player.nba_id).to eq(202696)

          play = Game.find_play_by_eventnum!(game, 67)
          expect(play.possession.visitor.points).to eq(15)
          expect(play.possession.home.points).to eq(14)

          play = Game.find_play_by_eventnum!(game, 74)
          expect(play.possession.visitor.points).to eq(17)
          expect(play.possession.home.points).to eq(14)

          play = Game.find_play_by_eventnum!(game, 76)
          expect(play.possession.visitor.points).to eq(18)
          expect(play.possession.home.points).to eq(14)

          play = Game.find_play_by_eventnum!(game, 156)
          expect(play.possession.team).to eq(nil)
          expect(play.possession.seconds_remaining).to eq(25)
          expect(play.possession.offense).to eq(:visitor)
          expect(play.possession_key => play.key).to eq(ball_in_play: [ :rebound, team: :offense ])
          expect(play.possession.visitor.points).to eq(25)
          expect(play.possession.home.points).to eq(22)

          play = Game.find_play_by_eventnum!(game, 157)
          expect(play.possession.team).to eq(:visitor)
          expect(play.possession_key => play.key).to eq(team: [ :steal ])
          expect(play.possession.seconds_remaining).to eq(24)
          expect(play.possession.period).to eq(1)

          play = Game.find_play_by_eventnum!(game, 159)
          expect(play.possession.team).to eq(:home)
          expect(play.possession.period).to eq(1)
          expect(play.possession.seconds_remaining).to eq(21)
          expect(play.seconds).to eq(21)

          play = Game.find_play_by_eventnum!(game, 164)
          expect(play.possession.home.period_personal_fouls).to eq(0)
          expect(play.possession.visitor.period_personal_fouls).to eq(0)
          expect(play.possession.period).to eq(2)
          expect(play.possession.team).to eq(:visitor)
          expect(play.possession.seconds_remaining).to eq(720)

          play = Game.find_play_by_eventnum!(game, 178)
          expect(play.possession.team).to eq(:visitor)
          expect(play.possession_key => play.key).to eq(team: [ :turnover ])

          play = Game.find_play_by_eventnum!(game, 179)
          expect(play.possession.team).to eq(:home)
          expect(play.possession.home.period_personal_fouls).to eq(0)
          expect(play.possession.visitor.period_personal_fouls).to eq(0)
          expect(play.possession_key => play.key).to eq(team: [ :shooting_foul ])
          expect(play.possession.play.opponent.nba_id).to eq(203932)
          expect(play.possession.play.player.nba_id).to eq(202690)

          play = Game.find_play_by_eventnum!(game, 180)
          expect(play.possession.home.period_personal_fouls).to eq(0)
          expect(play.possession.visitor.period_personal_fouls).to eq(1)

          play = Game.find_play_by_eventnum!(game, 187)
          expect(play.possession.home.period_personal_fouls).to eq(0)
          expect(play.possession_key => play.key).to eq(team: [ :fg ])

          play = Game.find_play_by_eventnum!(game, 189)
          expect(play.possession.home.period_personal_fouls).to eq(1)
          expect(play.possession_key => play.key).to eq(free_throws: [ :ft ])

          play = Game.find_play_by_eventnum!(game, 218)
          expect(play.possession.home.period_personal_fouls).to eq(1)
          expect(play.possession_key => play.key).to eq(team: [ :fg, and_one: true, assisted: true ])
          expect(play.possession.play.teammate.nba_id).to eq(203901)

          play = Game.find_play_by_eventnum!(game, 346)
          expect(play.possession_key => play.key).to eq(team: [ :fg, point_value: 3, assisted: true ])
          expect(play.possession.play.teammate.nba_id).to eq(203901)
          
          play = Game.find_play_by_eventnum!(game, 556)
          expect(play.possession.home.period_personal_fouls).to eq(2)

          play = Game.find_play_by_eventnum!(game, 568)
          expect(play.possession.period).to eq(4)
          expect(play.possession.home.period_personal_fouls).to eq(2)

          play = Game.find_play_by_eventnum!(game, 575)
          expect(play.possession.period).to eq(4)
          expect(play.possession.home.period_personal_fouls).to eq(3)

          play = game.plays.last
          expect(play.possession_key => play.key).to eq(team: [ :period_end ])

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
              points: game.possession.visitor.points
            },
            home: {
              points: game.possession.home.points
            }
          }

          expect(actual).to eq(expected)

          expect(game.plays.size).to eq(425)
          expect(game.possessions.size).to eq(426)
          expect(game.rows.size).to eq(512)
        end
      end
    end
  end
end
