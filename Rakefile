$LOAD_PATH << "lib"

require "play_by_play"
require "play_by_play/persistent/game"
require "play_by_play/repository"
require "play_by_play/sample/game"
require "play_by_play/sample/league"
require "play_by_play/sample/season"
require "play_by_play/simulation/game"
require "play_by_play/simulation/season"
require "play_by_play/views/possession"
require "play_by_play/views/season"

task default: [ "play:game" ]

namespace :play do
  desc "Play a single sample game"
  task :game do
    unless File.exist?("play_by_play_development.db")
      Rake::Task["import:season"].invoke
    end

    game = PlayByPlay::Persistent::Game.new
    possession = PlayByPlay::Simulation::Game.play!(game)
    view = PlayByPlay::Views::Possession.new(possession)
    puts view
  end

  desc "Simulate a season of games"
  task :season do
    args = {}

    if ENV["GAMES"]
      args[:scheduled_games_per_teams_count] = ENV["GAMES"].to_i
    end

    if ENV["TEAMS"]
      args[:teams_count] = ENV["TEAMS"].to_i
    end

    repository = PlayByPlay::Repository.new
    repository.create
    if repository.sample_league?
      args[:league] = PlayByPlay::Simulation::League.new_from_sample(repository.sample_league)
    end

    season = PlayByPlay::Simulation::Season.new(args)
    season = season.play!
    view = PlayByPlay::Views::Season.new(season)
    puts view
  end
end

namespace :parse do
  desc "Parse historical play by play file in memory"
  task :game do
    game_id = ENV["GAME_ID"] || "0021400001"
    file = PlayByPlay::Sample::Game.new(game_id, "ORL", "NOP")
    dir = ENV["DIR"] || "spec/data"
    json = file.read_json(dir)
    file.parse json, invalid_state_error: ENV["DEBUG"]
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
    PlayByPlay::Repository.new.create
    game_id = ENV["GAME_ID"] || "0021400001"
    file = PlayByPlay::Sample::Game.new(game_id, "ORL", "NOP")
    dir = ENV["DIR"] || "spec/data"
    file.import dir, invalid_state_error: ENV["DEBUG"]
  end

  desc "Import season into database"
  task :season do
    PlayByPlay::Repository.new.create!
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
