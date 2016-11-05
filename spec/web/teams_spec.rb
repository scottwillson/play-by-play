require "spec_helper"
require "play_by_play/persistent/day"
require "play_by_play/persistent/game"
require "play_by_play/persistent/season"
require "play_by_play/persistent/team"

RSpec.describe "teams index page", web: true, js: true do
  before do
    repository = Capybara.app.repository
    repository.reset!

    game = PlayByPlay::Persistent::Game.new(
      nba_id: "0021400014",
      home: PlayByPlay::Persistent::Team.new(abbreviation: "CLE"),
      visitor: PlayByPlay::Persistent::Team.new(abbreviation: "GSW")
    )
    game.error_eventnum = 291
    season_id = repository.seasons.save PlayByPlay::Persistent::Season.new(start_at: Date.today)
    day_id = repository.days.save season_id, PlayByPlay::Persistent::Day.new(season_id: season_id)
    repository.games.save day_id, game

    spawn "npm run dist:test", chdir: "web"
    Process.wait
  end

  it "renders" do
    visit "/#teams"
    expect(page).to have_content "Play by Play"
    expect(page).to have_content "Teams"
  end
end
