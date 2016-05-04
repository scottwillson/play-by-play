require "play_by_play/model/play"
require "play_by_play/model/possession"

module PlayByPlay
  module Persistent
    class Play  < Model::Play
      attr_reader :possession
      attr_reader :row

      # { team: :visitor } => [ :fg, point_value: 3 ]
      def self.from_hash(hash)
        return hash unless hash.is_a?(Hash)

        possession = Model::Possession.new(hash.keys.first)
        play_attributes = hash.values.first.dup
        type = play_attributes.shift
        play_attributes = play_attributes.first || {}

        Play.new(type, play_attributes.merge(possession: possession))
      end

      def initialize(type, *attributes)
        attributes = attributes.first.dup

        @possession = attributes.delete(:possession)
        @row = attributes.delete(:row)

        super type, attributes
      end
    end
  end
end
