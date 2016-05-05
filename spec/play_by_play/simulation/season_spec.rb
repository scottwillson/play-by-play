require "spec_helper"
require "play_by_play/mock/repository"
require "play_by_play/simulation/season"

module PlayByPlay
  module Simulation
    RSpec.describe Season do
      describe ".new" do
        it "creates realistic number of days" do
          season = Season.new({})
          expect(season.days.size).to be > 100
          expect(season.games.size).to eq(1230)
        end

        it "creates teams" do
          season = Season.new(scheduled_games_per_teams_count: 2)
          expect(season.teams.size).to eq(30)
        end
      end

      describe "#play!" do
        it "plays games" do
          league = League.new(4)
          season = Season.new(league: league, scheduled_games_per_teams_count: 4, repository: Mock::Repository.new)
          season.play!
          expect(season.days.size).to be > 0
          expect(season.games.size).to eq(8)
        end

        it "tallies wins and losses" do
          league = League.new(4)
          season = Season.new(league: league, scheduled_games_per_teams_count: 4, repository: Mock::Repository.new)
          season.play!
          expect(season.games.all? { |game| game.possession.game_over? }).to be true
          expect(season.games.all?(&:winner)).to be true
          expect(season.teams.any? { |team| team.games.size > 0 }).to be true
          expect(season.teams.any? { |team| team.wins > 0 }).to be true
          expect(season.teams.any? { |team| team.losses > 0 }).to be true
        end
      end
    end
  end
end
