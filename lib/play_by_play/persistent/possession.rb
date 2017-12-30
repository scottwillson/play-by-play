require "play_by_play/model/possession"

module PlayByPlay
  module Persistent
    class Possession
      extend Forwardable

      attr_accessor :id

      attr_reader :game
      attr_reader :play

      def_delegators :@model,
                     :ball_in_play?,
                     :defense,
                     :free_throws?,
                     :game_over?,
                     :home,
                     :key,
                     :margin,
                     :next_team,
                     :offense,
                     :opening_tip,
                     :period,
                     :seconds,
                     :seconds=,
                     :seconds_remaining,
                     :team,
                     :team?,
                     :technical_free_throws?,
                     :visitor

      def initialize(attributes = {})
        attributes = attributes.dup

        self.game = attributes[:game]
        self.game_id = attributes[:game_id]
        @home_margin = attributes[:home_margin]
        self.id = attributes[:id]
        @offense = attributes[:offense]
        self.play = attributes[:play]
        self.play_id = attributes[:play_id]
        @visitor_margin = attributes[:visitor_margin]

        assign_model attributes
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

      def assign_model(attributes)
        @model = Model::Possession.new_from_attributes(attributes)
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

      def source
        game&.source
      end

      def visitor_id
        game&.visitor_id
      end

      def visitor_margin
        @visitor_margin || margin(:visitor)
      end

      def inspect
        attributes.to_s
      end

      def to_s
        "#<PlayByPlay::Persistent::Possession #{key} id: #{id} home_id: #{home_id} visitor_id: #{visitor_id} >"
      end
    end
  end
end
