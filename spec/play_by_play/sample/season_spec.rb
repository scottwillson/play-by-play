require "spec_helper"
require "play_by_play/sample/season"
require "play_by_play/repository"

module PlayByPlay
  module Sample
    RSpec.describe Season do
      describe ".import", database: true do
        it "creates Days of Games from all JSON files at a path" do
          repository = Repository.new
          repository.reset!

          season = Season.import("spec/data", repository: repository, invalid_state_error: false)

          expect(season.days.size).to eq(1)
          expect(season.games.size).to eq(3)

          season = repository.seasons.year(2014)
          expect(season)

          days = repository.days.year(2014)
          expect(days.size).to eq(1)
          expect(days.first.date).to eq(Date.new(2014, 10, 28))

          games = repository.games.day(days.first)
          expect(games.size).to eq(3)

          expect(season.source).to eq("sample")
        end
      end
    end
  end
end
