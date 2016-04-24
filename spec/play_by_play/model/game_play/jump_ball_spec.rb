require "spec_helper"
require "play_by_play/model/game_play"
require "play_by_play/model/play"
require "play_by_play/model/possession"

module PlayByPlay
  module Model
    module GamePlay
      RSpec.describe "#jump_ball" do
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
    end
  end
end
