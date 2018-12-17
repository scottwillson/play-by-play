require "spec_helper"
require "play_by_play/model/game_play"
require "play_by_play/model/play"
require "play_by_play/model/possession"

module PlayByPlay
  module Model
    module GamePlay
      RSpec.describe "#ft" do
        describe "pending free throws and technical FTs" do
          it "assigns possession after technical FT" do
            possession = Possession.new(team: :home, free_throws: [ :home ], technical_free_throws: [ :home ])
            possession = GamePlay.play!(possession, [ :ft, player: 0 ])
            expect(possession.free_throws).to eq([ :home ])
            expect(possession.home.points).to eq(1)
            expect(possession.team).to eq(:home)
            expect(possession.next_team).to eq(nil)
            expect(possession.offense).to eq(:home)
          end

          it "updates team, ball_in_play, and free throws" do
            possession = Possession.new(team: :home, free_throws: [ :home ], next_team: :visitor)
            possession = GamePlay.play!(possession, [ :ft, player: 0 ])
            expect(possession.free_throws).to eq([])
            expect(possession.home.points).to eq(1)
            expect(possession.errors?).to eq(false)
            expect(possession.team).to eq(:visitor)
            expect(possession.next_team).to eq(nil)
            expect(possession.offense).to eq(:visitor)
          end

          it "decrements technical free throws" do
            possession = Possession.new(team: :home, technical_free_throws: [ :home ], next_team: :visitor)
            next_possession = GamePlay.play!(possession, [ :ft, player: 0 ])
            expect(next_possession.free_throws).to eq([])
            expect(next_possession.technical_free_throws).to eq([])
          end
        end
      end
    end
  end
end
