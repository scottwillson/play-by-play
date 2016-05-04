require "play_by_play/persistent/conference"
require "play_by_play/persistent/division"

module PlayByPlay
  module Simulation
    class Conference < Persistent::Conference

      def initialize(attributes)
        attributes = attributes.dup
        teams = attributes.delete(:teams)
        super attributes

        create_divisons teams
      end

      def create_divisons(teams)
        @divisions = []
        return if teams.empty?

        size = 5
        if teams.size < 8
          size = teams.size
        elsif teams.size % 5 == 1
          size = 4
        end

        teams.each_slice(size).with_index do |division_teams, i|
          @divisions << Persistent::Division.new(name: "division_#{i}", teams: division_teams)
        end
      end
    end
  end
end
