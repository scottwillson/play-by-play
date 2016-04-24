require "spec_helper"
require "play_by_play/model/possession"
require "play_by_play/views/possession"

module PlayByPlay
  module Views
    RSpec.describe Possession do
      describe "#to_s" do
        it "prints team points" do
          possession = Model::Possession.new
          view = Views::Possession.new(possession)
          expect(view.to_s).to eq "visitor 0\nhome 0\n"
        end
      end
    end
  end
end
