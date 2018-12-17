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

        Persistent::GamePlay.add_play sample_game, Model::Play.new(:jump_ball, team: :visitor, teammate: 1, opponent: 0, player: 0)
        Persistent::GamePlay.add_play sample_game, Model::Play.new(:personal_foul, team: :defense, opponent: 1, player: 2) # home (visitor on offense)
        Persistent::GamePlay.add_play sample_game, Model::Play.new(:personal_foul, team: :defense, opponent: 5, player: 2) # home (visitor on offense)
        Persistent::GamePlay.add_play sample_game, Model::Play.new(:fg, assisted: true, teammate: 0, player: 0) # visitor
        Persistent::GamePlay.add_play sample_game, Model::Play.new(:fg, point_value: 3, assisted: true, teammate: 0, player: 0) # home
        Persistent::GamePlay.add_play sample_game, Model::Play.new(:fg, point_value: 3, assisted: true, teammate: 1, player: 3) # visitor
        Persistent::GamePlay.add_play sample_game, Model::Play.new(:fg_miss, player: 12) # home
        Persistent::GamePlay.add_play sample_game, Model::Play.new(:rebound, team: :defense, player: 4) # visitor
        Persistent::GamePlay.add_play sample_game, Model::Play.new(:fg, point_value: 3, player: 1) # visitor

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
