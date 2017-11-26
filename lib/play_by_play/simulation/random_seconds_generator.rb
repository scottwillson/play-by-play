require "play_by_play/sample/seconds_probability_distribution"

module PlayByPlay
  module Simulation
    class RandomSecondsGenerator
      attr_reader :seconds_probability_distribution

      def initialize(repository = nil)
        @seconds_probability_distribution = Sample::SecondsProbabilityDistribution.new(repository)
      end

      # +random_number+ argument (0.0 - 1.0) for testing
      def seconds(possession, random_number = rand)
        probabilities = @seconds_probability_distribution.for(possession)
        aggregate_probabilty = probabilities.map(&:probability).reduce(:+)

        validate! probabilities, random_number, aggregate_probabilty, possession

        r = random_number * aggregate_probabilty
        previous_probability = 0

        probabilities.each do |seconds_probability|
          if r < previous_probability + seconds_probability.probability
            return seconds_probability.seconds
          end
          previous_probability += seconds_probability.probability
        end

        raise StandardError, "Did not find seconds for #{r} in #{probabilities} total #{aggregate_probabilty}"
      end

      def validate!(probabilities, random_number, aggregate_probabilty, possession)
        raise(ArgumentError, "random must be positive number less than 1, but was: #{random_number}") if random_number.negative? || random_number >= 1
        raise(ArgumentError, "probabilities cannot be empty for #{possession.play.type}") if probabilities.empty?
        raise(ArgumentError, "At least one SecondsProbability must be greater than 0 for #{possession}") if aggregate_probabilty.zero?
      end
    end
  end
end
