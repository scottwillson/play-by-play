require "play_by_play/simulation/division"

module PlayByPlay
  module Simulation
    class Conference
      attr_reader :divisions
      attr_reader :name
      attr_reader :teams

      def initialize(name, teams)
        @name = name
        @teams = teams
        create_divisons
      end

      def create_divisons
        size = 5
        if @teams.size < 8
          size = @teams.size
        elsif @teams.size % 5 == 1
          size = 4
        end

        @divisions = []
        teams.each_slice(size).with_index do |teams, i|
          @divisions << Division.new("division_#{i}", teams)
        end
      end
    end
  end
end
