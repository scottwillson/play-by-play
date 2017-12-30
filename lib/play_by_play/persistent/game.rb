require "play_by_play/persistent/possession"
require "play_by_play/persistent/team"

module PlayByPlay
  module Persistent
    class Game
      attr_accessor :error_eventnum
      attr_accessor :id

      attr_reader :day
      attr_reader :day_id
      attr_reader :errors
      attr_reader :home_id
      attr_reader :nba_id
      attr_reader :possessions
      attr_reader :rows
      attr_reader :visitor_id

      def initialize(
        day: nil,
        day_id: nil,
        id: nil,
        errors: [],
        error_eventnum: nil,
        home: Persistent::Team.new,
        home_id: nil,
        nba_id: nil,
        rows: [],
        visitor: Persistent::Team.new,
        visitor_id: nil
      )

        self.day_id = day_id
        self.day = day
        @errors = errors
        @error_eventnum = error_eventnum
        self.home_id = home_id
        self.home = home
        @id = id
        @nba_id = nba_id
        @rows = rows
        @possessions = [ Persistent::Possession.new(game: self) ]
        self.visitor_id = visitor_id
        self.visitor = visitor

        raise(ArgumentError, "Vistor team cannot be nil") if @visitor.nil?
        raise(ArgumentError, "Home team cannot be nil") if @home.nil?
        raise(Model::InvalidStateError, "Team cannot play itself. Visitor: #{@visitor}, home: #{@home}") if @home == @visitor
      end

      def day=(day)
        if day&.games && !day.games.include?(self)
          day.games << self
        end
        @day_id = day&.id
        @day = day
      end

      def day_id=(value)
        @day_id = value
        if @day&.id != value
          @day = nil
        end
      end

      def home
        raise "Team not set" if @home_id && @home.nil?
        @home
      end

      def home=(team)
        @home = team
        @home_id = team&.id
      end

      def home_id=(value)
        @home_id = value
        if @home&.id != value
          @home = nil
        end
      end

      def loser
        if possession.home.points < possession.visitor.points
          home
        elsif possession.home.points > possession.visitor.points
          visitor
        end
      end

      def plays
        possessions.map(&:play).compact
      end

      def possession
        possessions.last
      end

      def season
        day&.season
      end

      def source
        season&.source
      end

      def visitor
        raise "Team not set" if @visitor_id && @visitor.nil?
        @visitor
      end

      def visitor=(team)
        @visitor = team
        @visitor_id = team&.id
      end

      def visitor_id=(value)
        @visitor_id = value
        if @visitor&.id != value
          @visitor = nil
        end
      end

      def winner
        if possession.home.points > possession.visitor.points
          home
        elsif possession.home.points < possession.visitor.points
          visitor
        end
      end

      def to_s
        "#<PlayByPlay::Persistent::Game #{id}>"
      end
    end
  end
end
