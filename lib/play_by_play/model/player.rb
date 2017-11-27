require "play_by_play/model/duplication"

module PlayByPlay
  module Model
    # Detail of possession's player state in a game
    class Player
      include Duplication
      def ==(other)
        self.class == other.class && key == other.key
      end
    end
  end
end
