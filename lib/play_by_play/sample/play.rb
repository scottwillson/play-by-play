module PlayByPlay
  module Sample
    class Play
      attr_reader :possession
      attr_reader :key
      attr_reader :row
      attr_reader :seconds

      def self.from_hash(hash)
        return hash unless hash.is_a?(Hash)

        possession_attributes = hash.keys.first
        play_key = hash.values.first
        Sample::Play.new(Model::Possession.new(possession_attributes), play_key)
      end

      def initialize(possession, key, row = nil)
        @possession = possession
        @key = key
        @row = row
        @seconds = row&.seconds
      end

      def possession_key
        possession.key
      end
    end
  end
end
