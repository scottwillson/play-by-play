require "play_by_play/repository/base"

module PlayByPlay
  module RepositoryModule
    class League < Base
      def find
        league = Persistent::League.new(id: @db[:leagues].first[:id])

        @db[:conferences].where(league_id: league.id).each do |conference_attributes|
          conference = Persistent::Conference.new(id: conference_attributes[:id], name: conference_attributes[:name], league_id: league.id)
          league.conferences << conference

          @db[:divisions].where(conference_id: conference.id).each do |division_attributes|
            division = Persistent::Division.new(id: division_attributes[:id], name: division_attributes[:name], conference_id: conference.id)
            conference.divisions << division

            @db[:teams].where(division_id: division.id).each do |team_attributes|
              team = Persistent::Team.new(id: team_attributes[:id], abbreviation: team_attributes[:abbreviation], name: team_attributes[:name], division_id: division.id)
              division.teams << team
            end
          end
        end

        league
      end

      def exists?
        !@db[:leagues].empty?
      end

      def save(league)
        league.id = @db[:leagues].insert
        league.conferences.each do |conference|
          conference.id = @db[:conferences].insert(league_id: league.id, name: conference.name)
          conference.divisions.each do |division|
            division.id = @db[:divisions].insert(conference_id: conference.id, name: division.name)
            division.teams.each do |team|
              team.id = @db[:teams].insert(division_id: division.id, name: team.name, abbreviation: team.abbreviation)
            end
          end
        end
        true
      end

      def schedule(year)
        season = repository.seasons.year(year)
        season.league = find
        season.days = repository.days.year(year)
        repository.games.add_to(season)
        season
      end
    end
  end
end
