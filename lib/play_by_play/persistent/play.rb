require "play_by_play/model/play"
require "play_by_play/model/possession"

module PlayByPlay
  module Persistent
    class Play
      extend Forwardable

      attr_accessor :id
      attr_reader :possession
      attr_reader :possession_id
      attr_reader :row

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
                     :seconds=,
                     :team,
                     :type

      # [ :fg, point_value: 3 ]
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
      def self.from_hash(hash)
        return hash unless hash.is_a?(Hash)

        possession = Persistent::Possession.new(hash.keys.first)
        play_attributes = hash.values.first.dup
        type = play_attributes.shift
        play_attributes = play_attributes.first || {}

        Play.new type, play_attributes.merge(possession: possession)
      end

      def self.from_model(model, possession)
        self.new model.type, model: model
      end

      def initialize(type, *attributes)
        attributes = attributes.first.dup || {}

        @id = attributes[:id]
        self.possession = attributes[:possession]
        self.possession_id = attributes[:possession_id]
        self.row = attributes[:row]
        self.row_id = attributes[:row_id]

        assign_model type, attributes
      end

      def assign_model(type, attributes)
        @model = attributes[:model] || Model::Play.new_from_attributes(type, attributes)
      end

      def possession=(possession)
        return unless possession
        @possession = possession
        @possession_id = possession&.id
        possession.play = self
      end

      def possession_id=(value)
        @possession_id = value
        if @possession && value != @possession.id
          raise ArgumentError, "Can't set possession_id to #{value} with possession already set with ID #{value}"
        end
      end

      def possession_key
        possession&.key
      end

      def row=(value)
        @row = value
        @row_id = value&.id
      end

      def row_id
        @row&.id || @row_id
      end

      def row_id=(value)
        @row_id = value
        if @row && value != @row.id
          raise ArgumentError, "Can't set row_id to #{value} with row already set with ID #{value}"
        end
      end

      def inspect
        {
          id: id,
          possession_id: possession_id,
          row_id: row_id,
          type: type
        }.merge(@model&.attributes).to_s
      end

      def to_s
        "#<PlayByPlay::Persistent::Play #{id} #{type}>"
      end
    end
  end
end
