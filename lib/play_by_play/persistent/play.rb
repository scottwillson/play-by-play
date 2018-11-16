module PlayByPlay
  module Persistent
    class Play
      extend Forwardable
      def_delegators :@model,
                     :key,
                     :seconds

      attr_accessor :id
      attr_accessor :row
      attr_reader :possession
      attr_reader :possession_id

      # [ :fg, point_value: 3 ]
      # TODO move to model or remove?
      def self.from_array(array)
        type = array.first
        attributes = if array.size > 1
                       array.last
                     else
                       {}
                     end
        Play.new type, attributes
      end

      # { team: :visitor } => [ :fg, point_value: 3 ]
      # TODO move to model or remove?
      def self.from_hash(hash)
        return hash unless hash.is_a?(Hash)

        possession = Persistent::Possession.new(hash.keys.first)
        play_attributes = hash.values.first.dup
        type = play_attributes.shift
        play_attributes = play_attributes.first || {}

        Play.new(type, play_attributes.merge(possession: possession))
      end

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
          raise Model::InvalidStateError, "Persistent::Play #{to_s} already has possession #{possession.to_s}"
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
