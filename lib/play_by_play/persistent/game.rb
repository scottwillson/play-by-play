require "play_by_play/persistent/possession"
require "play_by_play/persistent/team"

module PlayByPlay
  module Persistent
    class Game
      attr_accessor :error_eventnum
      attr_accessor :id

      attr_reader :errors
      attr_reader :home
      attr_reader :nba_game_id
      attr_reader :possessions
      attr_accessor :rows
      attr_reader :visitor

      def initialize(home: Persistent::Team.new(key: :home), nba_game_id: nil, visitor: Persistent::Team.new(key: :visitor))
        @errors = []
        @home = home.merge(key: :home)
        @nba_game_id = nba_game_id
        @possessions = [ Persistent::Possession.new ]
        @rows = []
        @visitor = visitor.merge(key: :visitor)

        raise(Model::InvalidStateError, "Team cannot play itself") if @home == @visitor
      end

      def plays
        possessions.map(&:play).compact
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
