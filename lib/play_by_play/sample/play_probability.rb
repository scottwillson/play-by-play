module PlayByPlay
  module Sample
    class PlayProbability
      attr_reader :play
      attr_reader :probability

      def initialize(probability, *play)
        @play = play
        @probability = probability
        validate!
      end

      def validate!
        unless probability >= 0
          raise(ArgumentError, "probability must be a positive number, but is: #{probability} for #{play}")
        end
      end

      def to_s
        "#<Sample::PlayProbability #{probability} #{play.key}>"
      end
    end
  end
end
