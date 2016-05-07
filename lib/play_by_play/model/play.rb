module PlayByPlay
  module Model
    # A Redux "action" or a finite-state machine transition.
    class Play
      TYPES = [
        :block,
        :fg,
        :fg_miss,
        :ft,
        :ft_miss,
        :jump_ball,
        :jump_ball_out_of_bounds,
        :offensive_foul,
        :period_end,
        :personal_foul,
        :rebound,
        :shooting_foul,
        :steal,
        :team_rebound,
        :technical_foul,
        :turnover
      ].freeze

      attr_reader :and_one
      attr_reader :assisted
      attr_reader :away_from_play
      attr_reader :clear_path
      attr_reader :flagarant
      attr_reader :intentional
      attr_reader :point_value
      attr_reader :seconds
      attr_reader :team
      attr_reader :type

      def initialize(
        type,
        and_one: false,
        assisted: false,
        away_from_play: false,
        clear_path: false,
        flagarant: false,
        intentional: false,
        point_value: 2,
        seconds: 7,
        team: nil
      )

        @and_one = and_one
        @assisted = assisted
        @away_from_play = away_from_play
        @clear_path = clear_path
        @flagarant = flagarant
        @intentional = intentional
        @point_value = point_value
        @seconds = seconds
        @team = team
        @type = type

        validate!
      end

      def and_one?
        and_one
      end

      def away_from_play?
        away_from_play
      end

      def clear_path?
        clear_path
      end

      def flagarant?
        flagarant
      end

      def intentional?
        intentional
      end

      def possession_key
        possession.key
      end

      def validate!
        raise(ArgumentError, "Unknown Play type '#{type}'. Expected: #{TYPES.join(', ')}.") unless TYPES.include?(type)
      end

      def attributes
        return @attributes if @attributes

        @attributes = {}
        @attributes = @attributes.merge(point_value: point_value) if point_value == 3
        @attributes = @attributes.merge(and_one: true) if and_one?
        @attributes = @attributes.merge(away_from_play: true) if away_from_play?
        @attributes = @attributes.merge(assisted: true) if assisted
        @attributes = @attributes.merge(clear_path: true) if clear_path?
        @attributes = @attributes.merge(flagarant: true) if flagarant?
        @attributes = @attributes.merge(intentional: true) if intentional?

        if team && [ :jump_ball, :jump_ball_out_of_bounds, :personal_foul, :rebound, :team_rebound, :technical_foul ].include?(type)
          @attributes = @attributes.merge(team: team)
        end

        if team && type == :turnover
          @attributes = @attributes.merge(team: team)
        end

        @attributes
      end

      def key
        if attributes.empty?
          [ type ]
        else
          [ type, attributes ]
        end
      end
    end
  end
end
