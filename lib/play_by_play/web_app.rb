require "json"
require "sinatra/base"
require "sinatra/json"
require "play_by_play"
require "play_by_play/repository"

module PlayByPlay
  class WebApp < Sinatra::Application
    set :repository, PlayByPlay::Repository.new
    set :public_folder, "web/dist"

    get "/" do
      send_file File.join(settings.public_folder, "index.html")
    end

    get "/games.json" do
      page = (params["page"] || 1).to_i
      page = 1 if page < 1
      json repository.games(page)
    end

    get "/games/:nba_id.json" do |nba_id|
      json repository.rows(nba_id)
    end

    def repository
      settings.repository
    end
  end
end
