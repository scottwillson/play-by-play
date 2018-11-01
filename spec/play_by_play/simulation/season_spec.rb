require "spec_helper"
require "play_by_play/mock/repository"
require "play_by_play/simulation/league"
require "play_by_play/simulation/season"

module PlayByPlay
  module Simulation
    RSpec.describe Season do
      describe "#new_random" do
        it "creates season with days and games" do
          season = Season.new_random
          expect(season.teams.size).to eq(30)
          expect(season.days.size).to be > 100
          expect(season.games.size).to eq(1230)
        end

        it "creates season with configurable number of days and games" do
          league = League.new_random(4)
          season = Season.new_random(league: league, scheduled_games_per_teams_count: 4)
          expect(season.teams.size).to eq(4)
          expect(season.days.size).to be > 0
          expect(season.games.size).to eq(8)
        end
      end

      describe "#play!" do
        it "plays default number of games" do
          repository = Mock::Repository.new
          repository.populate!

          league = League.new_random(4)
          season = Season.new_random(league: league, scheduled_games_per_teams_count: 4)
          repository.seasons.save season

          season = Season.play!(season: season, repository: repository)
          expect(season.games.all? { |game| game.possession.game_over? }).to be true
          expect(season.games.all?(&:winner)).to be true
          expect(season.teams.none? { |team| team.games.empty? }).to be true
          expect(season.teams.any? { |team| team.wins > 0 }).to be true
          expect(season.teams.any? { |team| team.losses > 0 }).to be true
          expect(season.source).to eq("simulation")
        end
      end
    end
  end
end
