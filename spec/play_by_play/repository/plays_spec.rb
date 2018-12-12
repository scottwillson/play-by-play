require "spec_helper"
require "play_by_play/repository"

module PlayByPlay
  RSpec.describe Repository do
    describe "#plays.count" do
      it "counts sample possessions only", database: true do
        repository = Repository.new
        repository.reset!

        season = Sample::Season.new_persistent
        day = Persistent::Day.new(season: season)
        game = Sample::Game.new_game("001", "GSW", "POR")
        game.day = day
        repository.seasons.save season

        home_team = repository.teams.find_by_abbrevation("POR")
        visitor_team = repository.teams.find_by_abbrevation("GSW")

        season = Simulation::Season.new_persistent
        day = Persistent::Day.new(season: season)
        game = Persistent::Game.new(day: day, home: home_team, visitor: visitor_team)
        game.day = day
        Persistent::Play.new(:jump_ball, teammate: 1, opponent: 0, player: 0, team: :home, possession: game.possessions.first)
        repository.seasons.save season

        count = repository.plays.count(nil, :home, home_team.id, :home, [ :jump_ball, team: :home ])
        expect(count).to eq(1)
      end
    end
  end
end
