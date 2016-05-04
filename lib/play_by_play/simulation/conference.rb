require "play_by_play/persistent/division"

module PlayByPlay
  module Simulation
    class Conference
      attr_reader :divisions
      attr_reader :name
      attr_reader :teams

      def initialize(name, teams = [])
        @name = name
        @teams = teams
        create_divisons
      end

      def create_divisons
        @divisions = []
        return if @teams.empty?

        size = 5
        if @teams.size < 8
          size = @teams.size
        elsif @teams.size % 5 == 1
          size = 4
        end

        teams.each_slice(size).with_index do |teams, i|
          @divisions << Persistent::Division.new(name: "division_#{i}", teams: teams)
        end
      end
    end
  end
end
