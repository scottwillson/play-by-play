ENV["RACK_ENV"] = "test"

require "capybara/rspec"
require "capybara-screenshot/rspec"
require "chromedriver-helper"
require "selenium/webdriver"
require "sinatra"

require "play_by_play"
raise("Specs must run in 'test' environment, but is '#{PlayByPlay.environment}'") unless PlayByPlay.environment == :test

require "play_by_play/simulation/generator_helper"
require "play_by_play/web_app"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = "tmp/spec_examples.txt"
  config.disable_monkey_patching!
  config.warnings = false

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.order = :random
  Kernel.srand config.seed

  config.include Capybara::DSL
  config.include PlayByPlay::Simulation::GeneratorHelper

  config.before(:all, web: true) do
    spawn "npm run dist:test", chdir: "web"
    Process.wait
  end
end

Capybara.app = PlayByPlay::WebApp
Capybara.javascript_driver = :selenium_chrome_headless
Capybara.save_path = "tmp/capybara"
Capybara::Screenshot.prune_strategy = :keep_last_run
