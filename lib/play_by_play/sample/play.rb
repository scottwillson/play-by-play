module PlayByPlay
  module Sample
    class Play
      attr_reader :possession
      attr_reader :key
      attr_reader :row
      attr_reader :seconds

      def self.from_hash(play)
        return play unless play.is_a?(Hash)

        array = play.first
        possession_key = array[0]
        play_key = array[1]
        Sample::Play.new(Model::Possession.new(possession_key), play_key)
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
