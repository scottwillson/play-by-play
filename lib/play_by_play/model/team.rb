require "play_by_play/model/duplication"

module PlayByPlay
  module Model
    # Detail of possession's team state in a game
    class Team
      include Duplication

      attr_reader :key
      attr_reader :period_personal_fouls
      attr_accessor :personal_foul_in_last_two_minutes
      attr_reader :points

      def initialize(key: :visitor, period_personal_fouls: 0, personal_foul_in_last_two_minutes: false, points: 0)
        @key = key
        @period_personal_fouls = period_personal_fouls
        @personal_foul_in_last_two_minutes = personal_foul_in_last_two_minutes
        @points = points

        validate!
      end

      def attributes
        @attributes ||= {
          key: key,
          period_personal_fouls: period_personal_fouls,
          personal_foul_in_last_two_minutes: personal_foul_in_last_two_minutes,
          points: points
        }
      end

      def next_foul_in_penalty?
        period_personal_fouls >= 4 || personal_foul_in_last_two_minutes
      end

      def validate!
        raise(ArgumentError, "key must be :home or :visitor") unless key == :home || key == :visitor
      end

      def ==(other)
        self.class == other.class && key == other.key
      end
    end
  end
end
