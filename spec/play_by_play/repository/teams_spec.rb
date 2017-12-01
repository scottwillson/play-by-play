require "spec_helper"
require "play_by_play/repository"
require "play_by_play/sample/season"

module PlayByPlay
  RSpec.describe Repository do
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

        Sample::Game.play! sample_game, :jump_ball, team: :visitor, home_jump: 0, visitor_jump: 0, tip: 0
        Sample::Game.play! sample_game, :personal_foul, team: :defense, player: 1, fouled: 2 # home (visitor on offense)
        Sample::Game.play! sample_game, :personal_foul, team: :defense, player: 1, fouled: 2 # home (visitor on offense)
        Sample::Game.play! sample_game, :fg, assisted: true, player: 0, teammate: 4 # visitor
        Sample::Game.play! sample_game, :fg, point_value: 3, assisted: true, player: 0, teammate: 2 # home
        Sample::Game.play! sample_game, :fg, point_value: 3, assisted: true, player: 0, teammate: 2 # visitor
        Sample::Game.play! sample_game, :fg_miss, player: 1 # home
        Sample::Game.play! sample_game, :rebound, team: :defense # visitor
        Sample::Game.play! sample_game, :fg, point_value: 3, player: 0 # visitor

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
  end
end
