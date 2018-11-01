require "play_by_play/persistent/conference"
require "play_by_play/persistent/division"
require "play_by_play/persistent/league"
require "play_by_play/persistent/team"

module PlayByPlay
  module Simulation
    module League
      def self.new_from_sample(sample_league)
        league = Persistent::League.new
        sample_league.conferences.each do |sample_conference|
          conference = Persistent::Conference.new(name: sample_conference.name)
          league.conferences << conference
          sample_conference.divisions.each do |sample_division|
            division = Persistent::Division.new(name: sample_division.name)
            conference.divisions << division
            sample_division.teams.each do |sample_team|
              division.teams << Persistent::Team.new(name: sample_team.name)
            end
          end
        end

        league
      end

      def self.new_random(teams_count = 30)
        teams = create_teams(teams_count)

        league = Persistent::League.new
        league.conferences << Persistent::Conference.new(name: "conference_1")
        league.conferences << Persistent::Conference.new(name: "conference_2")

        create_divisons league.conferences[0], teams[ 0, teams_count / 2 ]
        create_divisons league.conferences[1], teams[ teams_count / 2, teams_count ]

        league
      end

      def self.create_teams(teams_count)
        teams = []

        teams_count.times.with_index do |i|
          team = Persistent::Team.new(id: i, name: "team_#{i}", abbreviation: "T#{i}")
          13.times do |player_index|
            team.players << Persistent::Player.new(name: "Visitor Player #{player_index}")
          end
          teams << team
        end

        teams
      end

      def self.create_divisons(conference, teams)
        return if teams.empty?

        size = 5
        if teams.size < 8
          size = teams.size
        elsif teams.size % 5 == 1
          size = 4
        end

        teams.each_slice(size).with_index do |division_teams, i|
          conference.divisions << Persistent::Division.new(name: "division_#{i}", teams: division_teams)
        end
      end
    end
  end
end
