require "spec_helper"
require "play_by_play/repository"

module PlayByPlay
  RSpec.describe Repository do
    describe "#games.all" do
      it "returns array", database: true do
        repository = Repository.new
        repository.reset!
        expect(repository.games.all).to eq([])
      end
    end
  end
end
