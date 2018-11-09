require "spec_helper"
require "play_by_play/persistent/day"
require "play_by_play/persistent/game"
require "play_by_play/persistent/season"
require "play_by_play/model/team"

RSpec.describe "teams index page", web: true, js: true do
  before do
    repository = Capybara.app.repository
    repository.reset!

    season = PlayByPlay::Sample::Season.new_persistent
    day = PlayByPlay::Persistent::Day.new(season: season)
    game = PlayByPlay::Persistent::Game.new(
      day: day,
      nba_id: "0021400014",
      home: PlayByPlay::Persistent::Team.new(abbreviation: "CLE"),
      visitor: PlayByPlay::Persistent::Team.new(abbreviation: "GSW")
    )
    game.error_eventnum = 291
    repository.seasons.save season
  end

  it "renders" do
    visit "/teams"
    expect(page).to have_content "3FGM"
  end
end
