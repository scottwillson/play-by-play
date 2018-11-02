require "spec_helper"
require "play_by_play/mock/game"
require "play_by_play/persistent/day"
require "play_by_play/repository"
require "play_by_play/sample/season"
require "play_by_play/simulation/season"

module PlayByPlay
  RSpec.describe Repository do
    describe "#plays.count" do
      it "counts sample possessions only", database: true do
        repository = Repository.new
        repository.reset!

        season = Sample::Season.new_persistent
        day = Persistent::Day.new(season: season)
        game = Mock::Game.new_persistent("001", "GSW", "POR")
        game.day = day
        Persistent::Play.new(:jump_ball, team: :home, teammate: 0, opponent: 0, player: 0, possession: game.possessions.first)
        repository.seasons.save season

        home_team = repository.teams.find_by_abbrevation_with_players("POR")
        visitor_team = repository.teams.find_by_abbrevation_with_players("GSW")

        season = Simulation::Season.new_persistent
        day = Persistent::Day.new(season: season)
        game = Persistent::Game.new(day: day, home: home_team, visitor: visitor_team)
        game.day = day
        Persistent::Play.new(:jump_ball, team: :home, teammate: 0, opponent: 0, player: 0, possession: game.possessions.first)
        repository.seasons.save season

        count = repository.plays.count(nil, :home, home_team.id, [ :jump_ball, team: :home ])
        expect(count).to eq(1)
      end
    end
  end
end
