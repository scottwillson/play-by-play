module PlayByPlay
  module Model
    # A Redux "action" or a finite-state machine transition.
    class Play
      KEYS = %i[
        and_one
        assisted
        away_from_play
        clear_path
        flagrant
        intentional
        point_value
        seconds
        team
      ].freeze

      TYPES = %i[
        block
        fg
        fg_miss
        ft
        ft_miss
        jump_ball
        jump_ball_out_of_bounds
        offensive_foul
        period_end
        personal_foul
        rebound
        shooting_foul
        steal
        team_rebound
        technical_foul
        turnover
      ].freeze

      attr_accessor :seconds

      attr_reader :and_one
      attr_reader :assisted
      attr_reader :away_from_play
      attr_reader :clear_path
      attr_reader :flagrant
      attr_reader :intentional
      attr_reader :point_value
      attr_reader :team
      attr_reader :type

      def self.foul?(type)
        %i[ offensive_foul personal_foul shooting_foul technical_foul ].include?(type)
      end

      def self.jump_ball?(type)
        type == :jump_ball
      end

      def self.rebound?(type)
        type == :rebound
      end

      def self.shot?(type)
        %i[ fg fg_miss ft ft_miss technical_ft technical_ft_miss ].include?(type)
      end

      def self.steal?(type)
        type == :steal
      end

      def self.turnover?(type)
        type == :turnover
      end

      def self.new_from_attributes(type, attributes)
        a = attributes.slice(*KEYS)
        self.new type, a
      end

      def initialize(
        type,
        and_one: false,
        assisted: false,
        away_from_play: false,
        clear_path: false,
        flagrant: false,
        intentional: false,
        point_value: 2,
        seconds: 7.7,
        team: nil
      )

        @and_one = and_one
        @assisted = assisted
        @away_from_play = away_from_play
        @clear_path = clear_path
        @flagrant = flagrant
        @intentional = intentional
        @point_value = point_value || 2
        @seconds = seconds
        @team = team
        @type = type

        validate!
      end

      def and_one?
        and_one
      end

      def assisted?
        assisted
      end

      def attributes
        @attributes ||= create_attributes
      end

      def away_from_play?
        away_from_play
      end

      def clear_path?
        clear_path
      end

      def create_attributes
        attributes = {}

        attributes[:and_one] = true            if and_one?
        attributes[:assisted] = true           if assisted?
        attributes[:away_from_play] = true     if away_from_play?
        attributes[:clear_path] = true         if clear_path?
        attributes[:flagrant] = true           if flagrant?
        attributes[:intentional] = true        if intentional?
        attributes[:point_value] = point_value if point_value == 3
        attributes[:team] = team               if set_team?

        attributes
      end

      def flagrant?
        flagrant
      end

      def foul?
        Play.foul? type
      end

      def intentional?
        intentional
      end

      def jump_ball?
        Play.jump_ball? type
      end

      def key
        if attributes.empty?
          [ type ]
        else
          [ type, attributes ]
        end
      end

      def possession_key
        possession.key
      end

      def rebound?
        Play.rebound? type
      end

      def set_team?
        team && %i[
          jump_ball
          jump_ball_out_of_bounds
          personal_foul
          rebound
          team_rebound
          technical_foul
          turnover
        ].include?(type)
      end

      def shot?
        Play.shot? type
      end

      def steal?
        Play.steal? type
      end

      def turnover?
        Play.turnover? type
      end

      def technical_foul?
        type == :technical_foul
      end

      def validate_player_attribute(attribute)
        value = send(attribute)
        if value && (value < 0 || value > 12)
          raise(ArgumentError, "#{attribute}: must be player between 0-12, but was: #{value}")
        end
      end

      def validate!
        raise(ArgumentError, "Unknown Play type '#{type}'. Expected: #{TYPES.join(', ')}.") unless TYPES.include?(type)
      end

      def inspect
        to_s
      end

      def to_s
        key.to_s
      end
    end
  end
end
