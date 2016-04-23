require "spec_helper"
require "play_by_play/model/possession"

module PlayByPlay
  module Model
    RSpec.describe "Game identity" do
      describe "#key" do
        it "ignores all other attributes if there are technical free throws" do
          possession = Possession.new(free_throws: [ :home, :home ], team: :home, technical_free_throws: [ :visitor ])
          possession_2 = Possession.new(team: :visitor, technical_free_throws: [ :home ])
          expect(possession.key).to eq(possession_2.key)

          possession = Possession.new
          possession_2 = Possession.new(ball_in_play: true)
          expect(possession.key).to_not eq(possession_2.key)

          possession = Possession.new(team: :home)
          possession_2 = Possession.new(ball_in_play: true, team: :home)
          expect(possession.key).to eq(possession_2.key)
        end
      end

      describe "#==" do
        it "considers ball_in_play?, free_throws?, team?, technical_free_throws?" do
          p = Possession.new
          p2 = Possession.new
          p3 = Possession.new(ball_in_play: true)
          p4 = Possession.new(ball_in_play: true)
          p5 = Possession.new(ball_in_play: true, team: :home)
          p6 = Possession.new(free_throws: [ :visitor ], team: :visitor)
          p7 = Possession.new(free_throws: [ :home ], team: :home, technical_free_throws: [ :home ])

          expect(p).to eq(p2)
          expect(p).to_not eq(p3)
          expect(p).to_not eq(p4)
          expect(p).to_not eq(p5)
          expect(p).to_not eq(p6)
          expect(p).to_not eq(p7)
          expect(p3).to eq(p4)
          expect(p4).to_not eq(p5)
          expect(p5).to_not eq(p6)
          expect(p6).to_not eq(p7)
        end
      end
    end
  end
end
