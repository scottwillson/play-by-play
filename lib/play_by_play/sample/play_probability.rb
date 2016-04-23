module PlayByPlay
  module Sample
    class PlayProbability
      attr_reader :play
      attr_reader :probability

      def initialize(probability, play)
        @play = play
        @probability = probability
      end
    end
  end
end
