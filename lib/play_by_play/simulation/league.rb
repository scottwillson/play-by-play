require "play_by_play/persistent/league"
require "play_by_play/persistent/team"
require "play_by_play/simulation/conference"

module PlayByPlay
  module Simulation
    class League < Persistent::League
      def self.new_from_sample(sample)
        league = League.new(0)
        league.conferences.clear
        sample.conferences.each do |sample_conference|
          conference = Conference.new(sample_conference.name)
          league.conferences << conference
          sample_conference.divisions.each do |sample_division|
            teams = sample_division.teams.map { |team| Team.new(team.name) }
            division = Division.new(sample_division.name, teams)
            conference.divisions << division
            league.teams.push(*teams)
          end
        end

        league
      end

      def initialize(teams_count = 30)
        super()
        create_teams teams_count
      end

      def create_teams(teams_count)
        i = 0
        @teams = Array.new(teams_count) { Persistent::Team.new(name: "team_#{i += 1}") }
        @conferences = [
          Conference.new("conference_1", @teams[ 0, teams_count / 2 ]),
          Conference.new("conference_2", @teams[ teams_count / 2, teams_count ])
        ]
      end
    end
  end
end
