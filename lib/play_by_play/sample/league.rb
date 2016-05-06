require "play_by_play/persistent/conference"
require "play_by_play/persistent/division"
require "play_by_play/persistent/league"
require "play_by_play/persistent/team"

module PlayByPlay
  module Sample
    class League
      def self.import(path, year, repository: Repository.new)
        league = Persistent::League.new

        json = JSON.parse(File.read("#{path}/#{year}.json"))
        json.dig("content", "standings", "groups").each do |conference_node|
          conference = Persistent::Conference.new(name: conference_node["name"])
          league.conferences << conference
          conference_node["groups"].each do |division_node|
            division = Persistent::Division.new(name: division_node["name"])
            conference.divisions << division
            division_node["standings"]["entries"].each do |team_node|
              division.teams << Persistent::Team.new(name: team_node["team"]["displayName"])
            end
          end
        end

        @id = repository.save_sample_league(league)

        league
      end
    end
  end
end
