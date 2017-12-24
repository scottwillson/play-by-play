require "spec_helper"
require "play_by_play/persistent/game"
require "play_by_play/persistent/play"
require "play_by_play/persistent/player"
require "play_by_play/persistent/possession"

module PlayByPlay
  module Persistent
    RSpec.describe Play do
      describe ".from_array" do
        it "creates a new Play from array" do
          home = Persistent::Team.new(abbreviation: "SEA")
          visitor = Persistent::Team.new(abbreviation: "POR")
          13.times do |index|
            home.players << Persistent::Player.new(name: "Home Player #{index}")
            visitor.players << Persistent::Player.new(name: "Visitor Player #{index}")
          end
          game = Persistent::Game.new(home: home, visitor: visitor)
          game.possessions << Persistent::Possession.new(game: game, team: :visitor)

          play = Play.from_array([ :fg, point_value: 3, player: 9 ], game.possession)

          expect(play.type).to eq(:fg)
          expect(play.point_value).to eq(3)
          expect(play.player.name).to eq("Visitor Player 9")
        end

        it "set attributes" do
          play = Play.from_array([ :fg, point_value: 3, seconds: 6.2, player: 7 ], game)
          expect(play.type).to eq(:fg)
          expect(play.point_value).to eq(3)
          expect(play.seconds).to eq(6.2)
          expect(play.player).to eq(7)
        end
      end
    end
  end
end
