require "spec_helper"
require "play_by_play/persistent/game"
require "play_by_play/persistent/team"
require "play_by_play/views/game"

module PlayByPlay
  module Views
    RSpec.describe Game do
      describe "#to_s" do
        it "prints team points" do
          game = Persistent::Game.new(home: Persistent::Team.new(abbreviation: "POR"), visitor: Persistent::Team.new(abbreviation: "DAL"))
          view = Views::Game.new(game)
          expect(view.to_s).to eq "DAL 0\nPOR 0\n"
        end

        it "prints team points with abbreviation" do
          game = Persistent::Game.new(home: Persistent::Team.new(abbreviation: "POR"), visitor: Persistent::Team.new(abbreviation: "DAL"))
          view = Views::Game.new(game)
          expect(view.to_s).to eq "DAL 0\nPOR 0\n"
        end
      end
    end
  end
end
