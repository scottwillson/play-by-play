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
              division.teams << Persistent::Team.new(name: team_node["team"]["displayName"], abbreviation: abbreviation(team_node))
            end
          end
        end

        @id = repository.league.save(league)

        league
      end

      def self.abbreviation(node)
        abbreviation = node["team"]["abbreviation"]

        case abbreviation
        when "GS"
          "GSW"
        when "SA"
          "SAS"
        when "NO"
          "NOP"
        when "NY"
          "NYK"
        when "WSH"
          "WAS"
        when "UTAH"
          "UTA"
        else
          abbreviation
        end
      end
    end
  end
end
