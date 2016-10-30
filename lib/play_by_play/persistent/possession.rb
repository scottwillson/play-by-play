require "play_by_play/model/possession"

module PlayByPlay
  module Persistent
    class Possession < Model::Possession
      attr_accessor :game
      attr_accessor :id
      attr_accessor :game_id
      attr_accessor :play
      attr_accessor :play_id

      def initialize(attributes = {})
        attributes = attributes.dup

        self.game = attributes.delete(:game)
        self.game_id = attributes.delete(:game_id)
        self.id = attributes.delete(:id)
        self.play = attributes.delete(:play)
        self.play_id = attributes.delete(:play_id)

        super attributes
      end

      def attributes
        super.merge(
          game: game,
          game_id: game_id,
          id: id,
          play: play,
          play_id: play_id
        )
      end

      def game=(value)
        @game = value
        @game_id = value&.id
      end

      def game_id=(value)
        @game_id = value
        if @game_id != @game&.id
          @game = nil
        end
      end

      def play=(value)
        @play = value
        @play_id = value&.id
      end

      def play_id=(value)
        @play_id = value
        if @play_id != @play&.id
          @play = nil
        end
      end

      def to_s
        "#<PlayByPlay::Persistent::Possession #{key}>"
      end
    end
  end
end