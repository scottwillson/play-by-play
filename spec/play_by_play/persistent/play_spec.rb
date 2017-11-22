require "spec_helper"
require "play_by_play/persistent/play"

module PlayByPlay
  module Persistent
    RSpec.describe Play do
      describe ".from_array" do
        it "creates a new Play from array" do
          play = Play.from_array([ :fg, point_value: 3 ])
          expect(play.type).to eq(:fg)
          expect(play.point_value).to eq(3)
        end

        it "set attributes" do
          play = Play.from_array([ :fg, point_value: 3, seconds: 6.2 ])
          expect(play.type).to eq(:fg)
          expect(play.point_value).to eq(3)
          expect(play.seconds).to eq(6.2)
        end
      end
    end
  end
end
