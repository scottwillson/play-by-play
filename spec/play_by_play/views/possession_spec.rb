require "spec_helper"
require "play_by_play/model/possession"
require "play_by_play/views/possession"

module PlayByPlay
  module Views
    RSpec.describe Possession do
      describe "#score" do
        it "prints team totals" do
          possession = Model::Possession.new
          view = Views::Possession.new(possession)
          expect(view.to_s).to eq "visitor 0\nhome 0\n"
        end
      end

      describe "#game_over?" do
        it "defaults to false" do
          possession = Model::Possession.new
          expect(possession.game_over?).to eq false
        end
      end
    end
  end
end
