require "play_by_play/model/possession"
require "play_by_play/persistent/team"

module PlayByPlay
  module Persistent
    class Game
      attr_accessor :id

      attr_reader :home
      attr_reader :possessions
      attr_reader :visitor

      def initialize(home: Persistent::Team.new(key: :home), visitor: Persistent::Team.new(key: :visitor))
        @possessions = [ Model::Possession.new ]

        @home = home.merge(key: :home)
        @visitor = visitor.merge(key: :visitor)

        raise(Model::InvalidStateError, "Team cannot play itself") if @home == @visitor
      end

      def possession
        possessions.last
      end

      def loser
        return unless possession.game_over?

        if possession.home.points < possession.visitor.points
          home
        else
          visitor
        end
      end

      def winner
        return unless possession.game_over?

        if possession.home.points > possession.visitor.points
          home
        else
          visitor
        end
      end
    end
  end
end
