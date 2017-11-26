module PlayByPlay
  module Sample
    class SecondsProbability
      attr_reader :seconds
      attr_reader :probability

      def initialize(probability, seconds)
        raise(ArgumentError, "probability cannot be nil") if probability.nil?
        raise(ArgumentError, "seconds cannot be nil") if seconds.nil?

        @seconds = seconds
        @probability = probability
      end

      def to_s
        "#<Sample::SecondsProbability #{probability} #{seconds}>"
      end
    end
  end
end
