module PlayByPlay
  module Simulation
    class Team
      attr_reader :games
      attr_reader :name

      def initialize(name)
        @games = []
        @name = name
      end

      def wins
        games.select { |game| game.winner == self }.size
      end

      def losses
        games.select { |game| game.loser == self }.size
      end

      def inspect
        "#<PlayByPlay::Simulation::Team #{name}>"
      end

      def to_s
        name.to_s
      end
    end
  end
end
