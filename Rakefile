$LOAD_PATH << "lib"

require "play_by_play"
require "play_by_play/persistent/game"
require "play_by_play/repository"
require "play_by_play/sample/game"
require "play_by_play/sample/league"
require "play_by_play/sample/season"
require "play_by_play/simulation/game"
require "play_by_play/simulation/season"
require "play_by_play/views/game"
require "play_by_play/views/season"

task default: [ "play:game" ]

namespace :play do
  desc "Play a single sample game"
  task :game do
    repository = PlayByPlay::Repository.new
    repository.create
    unless repository.league.exists?
      Rake::Task["import:season"].invoke
    end

    repository = PlayByPlay::Repository.new

    visitor = repository.teams.find_by_abbrevation(ENV["VISITOR_TEAM"] || "ORL")
    home = repository.teams.find_by_abbrevation(ENV["HOME_TEAM"] || "NOP")

    game = PlayByPlay::Persistent::Game.new(home: home, visitor: visitor)
    possession = PlayByPlay::Simulation::Game.play!(game)
    view = PlayByPlay::Views::Game.new(possession)
    puts view
  end

  desc "Simulate a season of games"
  task :season do
    repository = PlayByPlay::Repository.new
    repository.create
    if repository.league.exists?
      league = repository.league.find
    else
      teams_count = ENV["TEAMS"]&.to_i || 30
      league = PlayByPlay::Simulation::League.new_random(teams_count)
    end

    scheduled_games_per_teams_count = ENV["GAMES"]&.to_i || 82
    season = PlayByPlay::Simulation::Season.new_random(league: league, scheduled_games_per_teams_count: scheduled_games_per_teams_count)

    season = PlayByPlay::Simulation::Season.play!(season: season, repository: repository)
    view = PlayByPlay::Views::Season.new(season)
    puts view
  end
end

namespace :parse do
  desc "Parse historical play by play file in memory"
  task :game do
    game_id = ENV["GAME_ID"] || "0021400001"
    game = PlayByPlay::Sample::Game.new_game(game_id, "ORL", "NOP")
    dir = ENV["DIR"] || "spec/data"
    json = PlayByPlay::Sample::Game.read_json(dir, game_id)
    PlayByPlay::Sample::Game.parse game, json, invalid_state_error: ENV["DEBUG"]
  end

  desc "Parse season and show errors but do not save"
  task :season do
    dir = ENV["DIR"] || "spec/data"
    PlayByPlay::Sample::Season.parse dir, invalid_state_error: ENV["DEBUG"]
  end
end

namespace :import do
  desc "Import historical play by play file into database"
  task :game do
    PlayByPlay::Repository.new.create!
    game_id = ENV["GAME_ID"] || "0021400001"
    game = PlayByPlay::Sample::Game.new_game(game_id, "ORL", "NOP")
    dir = ENV["DIR"] || "spec/data"
    PlayByPlay::Sample::Game.import(game, dir, invalid_state_error: ENV["DEBUG"])
  end

  desc "Import season into database"
  task :season do
    PlayByPlay::Repository.new.create
    dir = ENV["DIR"] || "spec/data"
    PlayByPlay::Sample::Season.import dir, invalid_state_error: ENV["DEBUG"]
  end

  desc "Import league"
  task :league do
    dir = ENV["DIR"] || "spec/data"
    PlayByPlay::Sample::League.import dir, 2014
  end
end

namespace :repository do
  desc "Erase and recreate repository"
  task :recreate do
    `bin/setup`
    PlayByPlay::Repository.new.create!
  end
end

namespace :spec do
  begin
    require "rspec/core/rake_task"

    desc "Run full-stack web spec"
    RSpec::Core::RakeTask.new(:web) do |t|
      t.rspec_opts = "--tag web"
    end

    desc "Run fast (no database, no servers) specs"
    RSpec::Core::RakeTask.new(:fast) do |t|
      t.rspec_opts = "--tag ~web --tag ~database"
    end

    desc "Run all specs"
    RSpec::Core::RakeTask.new(:all)
  rescue LoadError
  end
end
