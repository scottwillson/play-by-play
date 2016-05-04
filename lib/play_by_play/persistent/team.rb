require "play_by_play/model/team"

module PlayByPlay
  module Persistent
    class Team < Model::Team
      attr_accessor :id

      attr_reader :division_id
      attr_reader :games
      attr_reader :name

      def initialize(attributes)
        @games = []

        attributes = attributes.dup
        @name = attributes.delete(:name)
        super attributes
      end

      def wins
        games.select { |game| game.winner == self }.size
      end

      def losses
        games.select { |game| game.loser == self }.size
      end

      def inspect
        "#<PlayByPlay::Persistent::Team #{name}>"
      end

      def to_s
        name.to_s
      end
    end
  end
end
