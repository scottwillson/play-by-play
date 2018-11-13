module PlayByPlay
  module Persistent
    class Possession
      attr_accessor :id

      attr_reader :game
      attr_reader :play

      def initialize(attributes = {})
        attributes = attributes.dup

        self.game = attributes.delete(:game)
        self.game_id = attributes.delete(:game_id)
        @home_margin = attributes.delete(:home_margin)
        self.id = attributes.delete(:id)
        self.play = attributes.delete(:play)
        self.play_id = attributes.delete(:play_id)
        @visitor_margin = attributes.delete(:visitor_margin)
      end

      def attributes
        {
          game: game,
          game_id: game_id,
          id: id,
          play: play,
          play_id: play_id
        }
      end

      def defense_id
        case offense
        when :home
          game.visitor.id
        when :visitor
          game.home.id
        end
      end

      def game=(value)
        @game = value
        @game_id = value&.id
      end

      def game_id
        @game&.id || @game_id
      end

      def game_id=(value)
        return unless value
        @game_id = value
        if @game && value != @game.id
          raise ArgumentError, "Can't set game_id to #{value} with game already set with ID #{@game.id}"
        end
      end

      def home_id
        game&.home_id
      end

      def home_margin
        @home_margin || margin(:home)
      end

      def offense_id
        case offense
        when :home
          game.home.id
        when :visitor
          game.visitor.id
        end
      end

      def play=(value)
        @play = value
        @play_id = value&.id
      end

      def play_id
        @play&.id || @play_id
      end

      def play_id=(value)
        @play_id = value
        if @play && value != @play.id
          raise ArgumentError, "Can't set play_id to #{value} with play already set with ID #{value}"
        end
      end

      def visitor_id
        game&.visitor_id
      end

      def visitor_margin
        @visitor_margin || margin(:visitor)
      end

      def to_s
        "#<PlayByPlay::Persistent::Possession #{key} id: #{id} home_id: #{home_id} visitor_id: #{visitor_id} >"
      end
    end
  end
end
