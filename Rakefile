$LOAD_PATH << "lib"

require "play_by_play"
require "play_by_play/repository"
require "play_by_play/sample/game"
require "play_by_play/sample/season"
require "play_by_play/simulation/game"
require "play_by_play/views/possession"

task default: [ :play ]

desc "Play a single sample game"
task :play do
  unless File.exist?("play_by_play_development.db")
    Rake::Task["import:season"].invoke
  end

  game = PlayByPlay::Simulation::Game.new(PlayByPlay::Repository.new)
  possession = game.play!
  view = PlayByPlay::Views::Possession.new(possession)
  puts view
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
