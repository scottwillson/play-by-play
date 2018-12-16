require "play_by_play/model/duplication"
require "play_by_play/model/invalid_state_error"
require "play_by_play/model/play_matrix"
require "play_by_play/model/team"

module PlayByPlay
  module Model
    # Immutable snapshot of Game state
    class Possession
      include Duplication

      # team with possession
      attr_reader :team

      # last team with possession. Usually the same as team, but team can be nil. offense should only be nil at the start of periods.
      # team shooting next FT is the offense
      attr_reader :offense

      # team that receives ball next after all FTs
      attr_reader :next_team

      attr_reader :ball_in_play
      attr_reader :errors
      attr_reader :free_throws
      attr_reader :home
      attr_reader :opening_tip
      attr_reader :period
      attr_reader :visitor
      attr_reader :technical_free_throws
      # seconds remaining in current period
      attr_reader :seconds_remaining

      def initialize(
        ball_in_play: false,
        errors: [],
        free_throws: [],
        next_team: nil,
        offense: nil,
        opening_tip: nil,
        period: 1,
        team: nil,
        seconds_remaining: 720,
        visitor: {},
        home: {},
        technical_free_throws: []
      )

        @ball_in_play = ball_in_play
        @errors = errors
        @free_throws = free_throws
        @opening_tip = opening_tip
        @period = period
        @seconds_remaining = seconds_remaining
        @technical_free_throws = technical_free_throws

        @visitor = merge_team(visitor, :visitor)
        @home = merge_team(home, :home)

        @offense = offense
        @next_team = next_team
        @team = to_visitor_or_home_symbol(team)
        @offense = @team if @team

        @offense = to_visitor_or_home_symbol(@offense)
        @next_team = to_visitor_or_home_symbol(@next_team)

        validate!
      end

      def attributes
        @attributes ||= {
          ball_in_play: ball_in_play,
          errors: errors.dup,
          free_throws: free_throws.dup,
          home: dup_value(:home),
          next_team: next_team,
          offense: offense,
          opening_tip: opening_tip,
          period: period,
          seconds_remaining: seconds_remaining,
          team: team,
          technical_free_throws: technical_free_throws,
          visitor: dup_value(:visitor)
        }
      end

      def ball_in_play?
        ball_in_play
      end

      def errors?
        !errors.empty?
      end

      def free_throws?
        !free_throws.empty?
      end

      def last_free_throw?
        free_throws.size == 1
      end

      def last_technical_free_throw?
        technical_free_throws.size == 1
      end

      def margin(team)
        case team
        when :home
          team_instance(:home).points - team_instance(:visitor).points
        when :visitor
          team_instance(:visitor).points - team_instance(:home).points
        else
          raise(ArgumentError, "team must be :home or :visitor, but was #{team.class} #{team}")
        end
      end

      def game_over?
        period >= 4 && !seconds_remaining? && !tied? && key == :no_seconds_remaining
      end

      def pending_free_throws?
        free_throws? || technical_free_throws?
      end

      def period_can_end?
        !free_throws? && !technical_free_throws? && seconds_remaining <= 24
      end

      def seconds_remaining?
        seconds_remaining > 0
      end

      def team?
        !team.nil?
      end

      def technical_free_throws?
        !technical_free_throws.empty?
      end

      def tied?
        home.points == visitor.points
      end

      def teams
        [ visitor, home ]
      end

      def merge_team(team, key)
        if team.is_a?(Team)
          team
        else
          Team.new(key: key).merge(team)
        end
      end

      # :home or :visitor to Team
      def team_instance(team = :team, key = nil)
        case team
        when Team
          return team
        when Hash
          return team_instance(key).merge(team)
        end

        case to_visitor_or_home_symbol(team)
        when :visitor
          visitor
        when :home
          home
        when nil
          nil
        else
          raise ArgumentError, "team #{team} must be nil, :home, :visitor, or a Hash but is a #{team.class} #{team}"
        end
      end

      def to_visitor_or_home_symbol(value)
        case value
        when :defense
          other_team offense
        when :home
          :home
        when :offense
          to_visitor_or_home_symbol offense
        when :team
          team
        when :visitor
          :visitor
        when nil
          nil
        else
          raise ArgumentError, "team must be nil, :defense, :home, :offense, :team, or :visitor but is a #{value.class} #{value}"
        end
      end

      def other_team(value = team)
        case to_visitor_or_home_symbol(value)
        when :visitor
          :home
        when :home
          :visitor
        when nil
          nil
        else
          raise ArgumentError, "#{value} #{value.class} not valid for #other_team"
        end
      end

      def defense
        other_team offense
      end

      def to_h
        {
          team: @team,
          offense: @offense,
          next_team: @next_team,
          ball_in_play: @ball_in_play,
          free_throws: @free_throws,
          technical_free_throws: @technical_free_throws,
          period: @period,
          seconds_remaining: @seconds_remaining,
          opening_tip: @opening_tip,
          errors: @errors,
          visitor: @visitor,
          home: @home
        }
      end

      def ==(other)
        self.class == other.class && hash == other.hash
      end

      def eql?(other)
        self == other
      end

      def hash
        key.hash
      end

      def key
        if technical_free_throws?
          :technical_free_throws
        elsif free_throws?
          :free_throws
        elsif team?
          :team
        elsif ball_in_play?
          :ball_in_play
        elsif !seconds_remaining?
          :no_seconds_remaining
        end
      end

      private

      def validate!
        # API used incorrectly. Raise exception.
        validate_arguments!

        unless PlayMatrix.possession_key?(key)
          return [ "Possession key #{key} not found in #{PlayMatrix.possession_keys.join(', ')}" ]
        end

        if pending_free_throws? && ball_in_play?
          raise(InvalidStateError, "ball_in_play? can't be true if there are pending free throws")
        end

        if pending_free_throws? && team.nil?
          raise(InvalidStateError, "team must not be nil if free throws are pending")
        end

        if pending_free_throws? && offense.nil?
          raise(InvalidStateError, "offense can not be nil if free throws are pending")
        end

        if team && offense.nil?
          raise InvalidStateError, "offense must not be nil if team is not nil"
        end

        if team && offense != team
          raise InvalidStateError, "if team, offense must be same as team"
        end

        if seconds_remaining < 0
          raise InvalidStateError, "seconds_remaining must be >= 0 but is #{seconds_remaining}"
        end
      end

      def validate_arguments!
        raise(ArgumentError, "free_throws must be an Enumerable but are #{free_throws.class}") unless free_throws.is_a?(Enumerable)
        raise(ArgumentError, "technical_free_throws must be an Enumerable but are #{technical_free_throws.class}") unless technical_free_throws.is_a?(Enumerable)
        raise(ArgumentError, "free_throws must all be :home or :visitor but are #{free_throws}") unless free_throws.all? { |ft| ft == :home || ft == :visitor }
        raise(ArgumentError, "technical_free_throws must all be :home or :visitor but are #{technical_free_throws}") unless technical_free_throws.all? { |ft| ft == :home || ft == :visitor }
        raise(ArgumentError, "next_team must be nil, visitor, or home but was #{next_team.class} #{next_team}") unless valid_team?(next_team)
        raise(ArgumentError, "offense must be nil, visitor, or home but was #{offense.class} #{offense}") unless valid_team?(offense)
        raise(ArgumentError, "team must be nil, visitor, or home but was #{team.class} #{team}") unless valid_team?(team)
        raise(ArgumentError, "visitor must be Team") unless visitor.is_a?(Team)
        raise(ArgumentError, "home must be Team") unless home.is_a?(Team)
      end

      def valid_team?(team)
        [ nil, :visitor, :home ].include?(team)
      end
    end
  end
end
