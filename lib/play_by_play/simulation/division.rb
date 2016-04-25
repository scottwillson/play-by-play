module PlayByPlay
  module Simulation
    class Division
      attr_reader :name
      attr_reader :teams

      def initialize(name, teams)
        @name = name
        @teams = teams
      end
    end
  end
end
