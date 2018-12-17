module PlayByPlay
  module Persistent
    class Play
      extend Forwardable
      def_delegators :@model,
                     :and_one?,
                     :assisted?,
                     :away_from_play?,
                     :clear_path?,
                     :flagrant?,
                     :intentional?,
                     :key,
                     :point_value,
                     :seconds,
                     :team,
                     :type

      attr_accessor :id
      attr_accessor :row
      attr_reader :opponent
      attr_reader :player
      attr_reader :possession
      attr_reader :possession_id
      attr_reader :teammate

      def self.from_model(model)
        Persistent::Play.new(model.type, model.attributes.merge(seconds: model.seconds))
      end

      def initialize(type, *attributes)
        attributes = attributes.first.dup || {}

        @id = attributes.delete(:id)
        self.opponent = attributes.delete(:opponent)
        self.player = attributes.delete(:player)
        self.possession = attributes.delete(:possession)
        self.possession_id = attributes.delete(:possession_id)
        self.teammate = attributes.delete(:teammate)
        @row = attributes.delete(:row)

        self.opponent_id = attributes.delete(:opponent_id)
        self.player_id = attributes.delete(:player_id)
        self.teammate_id = attributes.delete(:teammate_id)

        # TODO convert players to ordinals for model
        @model = Model::Play.new(type, attributes)
      end

      def opponent=(value)
        return unless value

        unless value.is_a?(Player)
          raise ArgumentError, "opponent must be a Persistent::Player but was #{value.class}"
        end

        @opponent_id = @opponent&.id
      end

      def opponent_id
        opponent&.id || @opponent_id
      end

      def opponent_id=(value)
        @opponent_id = value
        if @opponent && value && value != @opponent.id
          raise ArgumentError, "Can't set opponent_id to #{value} with opponent already set with ID #{value}"
        end
      end

      def player=(value)
        return unless value

        unless value.is_a?(Player)
          raise ArgumentError, "player must be a Persistent::Player but was #{value.class}"
        end

        @player_id = @player&.id
      end

      def player_id
        player&.id || @player_id
      end

      def player_id=(value)
        @player_id = value
        if @player && value && value != @player.id
          raise ArgumentError, "Can't set player_id to #{value} with player already set with ID #{value}"
        end
      end

      def possession=(value)
        return unless value

        if possession
          raise Model::InvalidStateError, "Persistent::Play #{self} already has possession #{possession}"
        end

        @possession = value
        @possession_id = value&.id
        possession.play = self
      end

      def possession_id=(value)
        @possession_id = value
        if @possession && value != @possession.id
          raise ArgumentError, "Can't set possession_id to #{value} with possession already set with ID #{value}"
        end
      end

      def possession_key
        possession.key
      end

      def teammate=(value)
        return unless value

        unless value.is_a?(Player)
          raise ArgumentError, "teammate must be a Persistent::Player but was #{value.class}"
        end

        @teammate_id = @teammate&.id
      end

      def teammate_id
        teammate&.id || @opponent_id
      end

      def teammate_id=(value)
        @teammate_id = value
        if @teammate && value && value != @teammate.id
          raise ArgumentError, "Can't set teammate_id to #{value} with teammate already set with ID #{value}"
        end
      end
    end
  end
end
