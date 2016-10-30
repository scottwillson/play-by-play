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

    describe "#sample_league?" do
      it "checks for sample league in database", database: true do
        repository = Repository.new
        repository.reset!
        expect(repository.league.exists?).to be(false)
      end
    end
  end
end
