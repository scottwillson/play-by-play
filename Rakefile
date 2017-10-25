$LOAD_PATH << "lib"

require "play_by_play"
require "play_by_play/persistent/game"
require "play_by_play/repository"
require "play_by_play/sample/game"
require "play_by_play/sample/league"
require "play_by_play/sample/season"
require "play_by_play/simulation/game"
require "play_by_play/simulation/random_play_generator"
require "play_by_play/simulation/season"
require "play_by_play/views/game"
require "play_by_play/views/season"
require "play_by_play/views/teams"

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

    (ENV["TIMES"]&.to_i || 1).times do
      game = PlayByPlay::Persistent::Game.new(home: home, visitor: visitor)
      game = PlayByPlay::Simulation::Game.play!(game)
      puts PlayByPlay::Views::Game.new(game)
      puts
    end
  end

  desc "Simulate a season of games"
  task :season do
    repository = PlayByPlay::Repository.new
    repository.create

    days = ENV["DAYS"]&.to_i
    scheduled_games_per_teams_count = ENV["GAMES"]&.to_i || 82
    seasons = ENV["SEASONS"]&.to_i || 1
    year = ENV["YEAR"]&.to_i

    random_play_generator = PlayByPlay::Simulation::RandomPlayGenerator.new(repository)
    random_play_generator.play_probability_distribution.pre_fetch!

    seasons.times do
      if repository.league.exists?
        league = repository.league.find
      else
        teams_count = ENV["TEAMS"]&.to_i || 30
        league = PlayByPlay::Simulation::League.new_random(teams_count)
      end

      if year
        season = repository.league.schedule(year)
      else
        season = PlayByPlay::Simulation::Season.new_random(league: league, scheduled_games_per_teams_count: scheduled_games_per_teams_count)
      end

      PlayByPlay::Simulation::Season.play!(days: days, season: season, repository: repository, random_play_generator: random_play_generator)
      view = PlayByPlay::Views::Season.new(season)
      puts view

      view = PlayByPlay::Views::Teams.new(season)
      puts view

      repository.seasons.save season
    end
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

namespace :sample do
  desc "Show counts for POSSESSION, TEAM, TEAM_ID"
  task :distribution do
    repository = PlayByPlay::Repository.new

    possession_key = ENV["POSSESSION"].to_sym
    team = ENV["TEAM"].to_sym
    team_id = ENV["TEAM_ID"].to_i

    total_plays = PlayByPlay::Model::PlayMatrix.accessible_plays(possession_key).inject(0) do |total, play|
      total + repository.plays.count(possession_key, team, team_id, play)
    end

    fg = 0
    fg_miss = 0
    PlayByPlay::Model::PlayMatrix.accessible_plays(possession_key).each do |play|
      count = repository.plays.count(possession_key, team, team_id, play)
      if play.first == :fg
        fg = fg + count
      end
      if play.first == :fg_miss || play.first == :block
        fg_miss = fg_miss + count
      end
      puts "#{format "%.1f", count * 100 / total_plays.to_f}   #{play}"
    end

    puts "#{fg}/#{fg_miss + fg} #{fg/(fg + fg_miss).to_f}"
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
