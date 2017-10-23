require "spec_helper"
require "play_by_play/persistent/game"
require "play_by_play/persistent/team"
require "play_by_play/repository"
require "play_by_play/sample/game"

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

    describe "#teams.all" do
      it "returns array", database: true do
        repository = Repository.new
        repository.reset!

        team = Persistent::Team.new(name: "Portland Trail Blazers")
        repository.teams.create(team)

        teams = repository.teams.all
        expect(teams.size).to eq(1)
        expect(teams[0][:name]).to eq("Portland Trail Blazers")
        expect(teams[0][:points]).to eq(nil)
      end
    end

    describe "#teams.years" do
      it "returns array with no stats", database: true do
        repository = Repository.new
        repository.reset!

        team = Persistent::Team.new(name: "Portland Trail Blazers")
        repository.teams.create(team)

        teams = repository.teams.years
        expect(teams.size).to eq(0)
      end

      it "returns array with aggregate stats", database: true do
        repository = Repository.new
        repository.reset!

        portland = Persistent::Team.new(abbreviation: "POR", name: "Portland Trail Blazers")
        repository.teams.create(portland)

        golden_state = Persistent::Team.new(abbreviation: "GSW", name: "Golden State Warriors")
        repository.teams.create(golden_state)

        season = Sample::Season.new_persistent
        day = Persistent::Day.new(season: season)
        sample_game = Sample::Game.new_game("001", "GSW", "POR")
        sample_game.day = day

        Sample::Game.play! sample_game, :jump_ball, team: :visitor
        Sample::Game.play! sample_game, :personal_foul, team: :defense # home (visitor on offense)
        Sample::Game.play! sample_game, :personal_foul, team: :defense # home (visitor on offense)
        Sample::Game.play! sample_game, :fg, assisted: true # visitor
        Sample::Game.play! sample_game, :fg, point_value: 3, assisted: true # home
        Sample::Game.play! sample_game, :fg, point_value: 3, assisted: true # visitor
        Sample::Game.play! sample_game, :fg_miss # home
        Sample::Game.play! sample_game, :rebound, team: :defense # visitor
        Sample::Game.play! sample_game, :fg, point_value: 3 # visitor

        repository.seasons.save season

        teams = repository.teams.years
        expect(teams.size).to eq(2)
        teams = teams.sort_by { |t| t[:name] }
        expect(teams[0][:name]).to eq("Golden State Warriors")
        expect(teams[0][:points]).to eq(8)
        expect(teams[1][:name]).to eq("Portland Trail Blazers")
        expect(teams[1][:points]).to eq(3)
      end
    end

    describe "#plays.count" do
      it "counts sample possessions only" do
        repository = Repository.new
        repository.reset!

        season = Sample::Season.new_persistent
        day = Persistent::Day.new(season: season)
        game = Sample::Game.new_game("001", "GSW", "POR")
        game.day = day
        Persistent::Play.new(:jump_ball, team: :home, possession: game.possessions.first)
        repository.seasons.save season

        home_team = repository.teams.find_by_abbrevation("POR")
        visitor_team = repository.teams.find_by_abbrevation("GSW")

        season = Simulation::Season.new_persistent
        day = Persistent::Day.new(season: season)
        game = Persistent::Game.new(day: day, home: home_team, visitor: visitor_team)
        game.day = day
        Persistent::Play.new(:jump_ball, team: :home, possession: game.possessions.first)
        repository.seasons.save season

        count = repository.plays.count(nil, :home, home_team.id, [ :jump_ball, team: :home ])
        expect(count).to eq(1)
      end
    end
  end
end
