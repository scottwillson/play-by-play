require "spec_helper"
require "play_by_play/simulation/league"
require "play_by_play/simulation/season"
require "play_by_play/views/season"

module PlayByPlay
  module Views
    RSpec.describe Season do
      describe "#to_s" do
        it "prints records" do
          league = Simulation::League.new(4)
          season = Simulation::Season.new(league: league)
          view = Views::Season.new(season)
          expect(view.to_s).to include "team_1 0 0\n"
          expect(view.to_s).to include "team_4 0 0"
        end
      end
    end
  end
end
