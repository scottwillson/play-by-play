require "spec_helper"
require "play_by_play/sample/game"

RSpec.describe "index page", web: true, js: true do
  before do
    repository = Capybara.app.repository
    repository.reset!

    file = PlayByPlay::Sample::Game.new("0021400014", "GSW", "POR")
    file.error_eventnum = 291
    repository.save_sample_game file

    spawn "npm run dist:test", chdir: "web"
    Process.wait
  end

  it "renders" do
    visit "/"
    expect(page).to have_content "Play by Play"
    expect(page).to have_content "Game ID"

    click_link "21400014"
    expect(page).to have_css "th.eventnum"
  end
end
