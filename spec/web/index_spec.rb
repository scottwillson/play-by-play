require "spec_helper"
require "play_by_play/persistent/game"
require "play_by_play/persistent/team"
require "play_by_play/sample/season"

RSpec.describe "index page", web: true, js: true do
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
    visit "/"
    expect(page).to have_content "Game ID"

    click_link "21400014"
    expect(page).to have_css "th.eventnum"
  end
end
