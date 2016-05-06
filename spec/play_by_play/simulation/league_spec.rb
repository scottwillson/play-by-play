require "spec_helper"
require "play_by_play/simulation/league"

module PlayByPlay
  module Simulation
    RSpec.describe League do
      describe ".new_random" do
        it "creates conferences and divisions" do
          league = League.new_random
          expect(league.conferences.size).to eq(2)
          expect(league.conferences[0].divisions.size).to eq(3)
          expect(league.conferences[1].divisions.size).to eq(3)
          expect(league.conferences[0].divisions[0].teams.size).to eq(5)
          expect(league.conferences[1].divisions[2].teams.size).to eq(5)
        end

        it "can be arbritray size" do
          league = League.new_random(4)
          expect(league.conferences.size).to eq(2)
          expect(league.conferences[0].divisions.size).to eq(1)
          expect(league.conferences[0].divisions[0].teams.size).to eq(2)
        end
      end
    end
  end
end
