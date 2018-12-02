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
      attr_reader :possession
      attr_reader :possession_id

      def self.from_model(model)
        Persistent::Play.new(model.type, model.attributes.merge(seconds: model.seconds))
      end

      def initialize(type, *attributes)
        attributes = attributes.first.dup || {}

        @id = attributes.delete(:id)
        self.possession = attributes.delete(:possession)
        self.possession_id = attributes.delete(:possession_id)
        @row = attributes.delete(:row)
        @model = Model::Play.new(type, attributes)
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
    end
  end
end
