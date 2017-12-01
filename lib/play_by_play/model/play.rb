module PlayByPlay
  module Model
    # A Redux "action" or a finite-state machine transition.
    class Play
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
      attr_reader :assist
      attr_reader :assisted
      attr_reader :away_from_play
      attr_reader :clear_path
      attr_reader :flagrant
      attr_reader :foul
      attr_reader :fouled
      attr_reader :home_jump
      attr_reader :intentional
      attr_reader :point_value
      attr_reader :player
      attr_reader :steal
      attr_reader :team
      attr_reader :tip
      attr_reader :turnover
      attr_reader :type
      attr_reader :visitor_jump

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

      def initialize(
        type,
        and_one: false,
        assist: nil,
        assisted: false,
        away_from_play: false,
        clear_path: false,
        flagrant: false,
        foul: nil,
        fouled: nil,
        home_jump: nil,
        intentional: false,
        point_value: 2,
        player: nil,
        steal: nil,
        seconds: 7.7,
        team: nil,
        tip: nil,
        turnover: nil,
        visitor_jump: nil
      )

        @and_one = and_one
        @assist = assist
        @assisted = assisted
        @away_from_play = away_from_play
        @clear_path = clear_path
        @flagrant = flagrant
        @foul = foul
        @fouled = fouled
        @home_jump = home_jump
        @intentional = intentional
        @point_value = point_value || 2
        @player = player
        @seconds = seconds
        @steal = steal
        @team = team
        @tip = tip
        @type = type
        @turnover = turnover
        @visitor_jump = visitor_jump

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
        raise(ArgumentError, "assist: player required for #{type} in #{key}") if assisted? && assist.nil?
        raise(ArgumentError, "player required for #{type} in #{key}") if shot? && player.nil?
        raise(ArgumentError, "steal: player required for #{type} in #{key}") if steal? && steal.nil?
        raise(ArgumentError, "turnover: player required for #{type} in #{key}") if steal? && turnover.nil?
        raise(ArgumentError, "turnover: player required for #{type} in #{key}") if turnover? && turnover.nil?

        if foul? && !foul
          raise(ArgumentError, "foul: player required for #{type} in #{key}")
        end

        if foul? && !technical_foul? && !fouled
          raise(ArgumentError, "fouled: player required for #{type} in #{key}")
        end

        if jump_ball? && !home_jump
          raise(ArgumentError, "home_jump: player required for #{type} in #{key}")
        end

        if jump_ball? && !visitor_jump
          raise(ArgumentError, "visitor_jump: player required for #{type} in #{key}")
        end

        %w[ assist foul fouled home_jump player steal tip turnover visitor_jump ]
          .each { |attribute| validate_player_attribute(attribute) }
      end
    end
  end
end
