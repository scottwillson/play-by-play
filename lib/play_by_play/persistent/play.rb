require "play_by_play/model/play"
require "play_by_play/model/possession"
require "play_by_play/persistent/player"

module PlayByPlay
  module Persistent
    class Play < Model::Play
      attr_accessor :id
      attr_accessor :row
      attr_reader :opponent
      attr_reader :opponent_id
      attr_reader :player
      attr_reader :possession
      attr_reader :possession_id
      attr_reader :teammate
      attr_reader :teammate_id

      # [ :fg, point_value: 3 ], Persistent::Possession
      def self.from_array(array, possession)
        type = array.first
        attributes = if array.size > 1
                       array.last
                     else
                       {}
                     end

        attributes[:possession] = possession
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
        attributes = attributes.first.dup || {}

        self.possession = attributes.delete(:possession)
        self.possession_id = attributes.delete(:possession_id)

        @id = attributes.delete(:id)
        self.opponent = attributes.delete(:opponent)
        self.player = attributes.delete(:player)
        self.teammate = attributes.delete(:teammate)

        self.opponent_id = attributes.delete(:opponent_id)
        self.player_id = attributes.delete(:player_id)
        self.teammate_id = attributes.delete(:teammate_id)
        @row = attributes.delete(:row)

        super type, attributes
      end

      def opponent=(value)
        return unless value

        case value
        when Player
          @opponent = value
        when Integer
          team = possession.game.other_team(possession.team)
          @opponent = team.players[value]
        else
          raise ArgumentError, "opponent must be a Persistent::Player or Integer but was #{value.class}"
        end

        @opponent_id = @opponent&.id
      end

      def opponent_id=(value)
        @opponent_id = value
        if @opponent && value && value != @opponent.id
          raise ArgumentError, "Can't set opponent_id to #{value} with opponent already set with ID #{value}"
        end
      end

      def player=(value)
        return unless value

        case value
        when Player
          @player = value
        when Integer
          team = possession.game.team(possession.team)
          @player = team.players[value]
        else
          raise ArgumentError, "player must be a Persistent::Player or Integer but was #{value.class}"
        end

        @player_id = @player&.id
      end

      def player_id
        player&.id || @player_id
      end

      def player_id=(value)
        @player_id = value
        if @player && value && value != @player.id
          raise ArgumentError, "Can't set player_id to #{value} with player already set with ID #{value}"
        end
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

      def teammate=(value)
        return unless value

        case value
        when Player
          @teammate = value
        when Integer
          team = possession.game.team(possession.team)
          @teammate = team.players[value]
        else
          raise ArgumentError, "teammate must be a Persistent::Player or Integer but was #{value.class}"
        end

        @teammate_id = @teammate&.id
      end

      def teammate_id=(value)
        @teammate_id = value
        if @teammate && value && value != @teammate.id
          raise ArgumentError, "Can't set teammate_id to #{value} with teammate already set with ID #{value}"
        end
      end

      def validate_player_attribute(attribute)
        value = send(attribute)
        if value && !value.is_a?(Player)
          raise(ArgumentError, "#{attribute}: must be a Persistent::Player, but was: #{value.class} #{value}")
        end
      end
    end
  end
end
