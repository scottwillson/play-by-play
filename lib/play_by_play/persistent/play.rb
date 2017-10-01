require "play_by_play/model/play"
require "play_by_play/model/possession"

module PlayByPlay
  module Persistent
    class Play < Model::Play
      attr_accessor :id
      attr_accessor :row
      attr_reader :possession
      attr_reader :possession_id

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

        Play.new(type, play_attributes.merge(possession: possession))
      end

      def initialize(type, *attributes)
        attributes = attributes.first.dup

        @id = attributes.delete(:id)
        self.possession_id = attributes.delete(:possession_id)
        self.possession = attributes.delete(:possession)
        @row = attributes.delete(:row)

        super type, attributes
      end

      def possession=(value)
        return unless value
        @possession = value
        @possession_id = value&.id
      end

      def possession_id=(value)
        return unless value
        @possession_id = value
        if @possession&.id != value
          @possession = nil
        end
      end
    end
  end
end
