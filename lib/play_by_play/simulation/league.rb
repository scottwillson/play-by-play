require "play_by_play/simulation/conference"
require "play_by_play/simulation/team"

module PlayByPlay
  module Simulation
    class League
      attr_reader :conferences
      attr_reader :teams

      def initialize(teams_count = 30)
        create_teams teams_count
      end

      def create_teams(teams_count)
        i = 0
        @teams = Array.new(teams_count) { Team.new("team_#{i += 1}") }
        @conferences = [
          Conference.new("conference_1", @teams[ 0, teams_count / 2 ]),
          Conference.new("conference_2", @teams[ teams_count / 2, teams_count ])
        ]
      end
    end
  end
end
