# https://github.com/sinatra/sinatra/issues/1476
$LOADED_FEATURES << "fake/active_support/core_ext/hash"

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 2.5"

gem "pg"
gem "puma"
gem "rack"
gem "rake"
gem "sequel"
gem "sequel_pg"
gem "sinatra"
gem "sinatra-contrib"
gem "text-table"

group :development do
  gem "rubocop"
end

group :test do
  gem "capybara"
  gem "capybara-screenshot"
  gem "chromedriver-helper"
  gem "rspec"
  gem "selenium-webdriver"
end
