require "play_by_play/sample/play_probability_distribution"

module PlayByPlay
  module Simulation
    class RandomPlayGenerator
      attr_reader :play_probability_distribution

      def initialize(repository = nil)
        @play_probability_distribution = Sample::PlayProbabilityDistribution.new(repository)
      end

      # +random_number+ argument (0.0 - 1.0) for testing
      def new_play(possession, random_number = rand)
        probabilities = @play_probability_distribution.for(possession)
        aggregate_probabilty = probabilities.map(&:probability).reduce(:+)

        validate! probabilities, random_number, aggregate_probabilty, possession

        r = random_number * aggregate_probabilty.to_f
        previous_probability = 0

        probabilities.each do |play_probability|
          if r < previous_probability + play_probability.probability
            return add_player(play_probability.play)
          end
          previous_probability += play_probability.probability
        end

        raise StandardError, "Did not find play for #{r} in #{probabilities} total #{aggregate_probabilty}"
      end

      def validate!(probabilities, random_number, aggregate_probabilty, possession)
        raise(ArgumentError, "random must be positive number less than 1, but was: #{random_number}") if random_number.negative? || random_number >= 1
        raise(ArgumentError, "probabilities cannot be empty") if probabilities.empty?
        raise(ArgumentError, "At least one PlayProbability must be greater than 0 for #{possession}") if aggregate_probabilty.zero?
      end

      def add_player(play)
        case play.first
        when :fg, :fg_miss
          attributes = play[1] || {}
          if attributes[:assisted]
            attributes = attributes.merge(assist: rand(5))
          end
          [ play.first, attributes.merge(shot: rand(5)) ]
        when :ft, :ft_miss
          attributes = play[1] || {}
          [ play.first, attributes.merge(shot: rand(5)) ]
        when :jump_ball
          attributes = play[1] || {}
          [ play.first, attributes.merge(home_jump: rand(5), tip: rand(5), visitor_jump: rand(5)) ]
        when :personal_foul
          attributes = play[1] || {}
          [ play.first, attributes.merge(foul: rand(5), fouled: rand(5)) ]
        when :rebound
          attributes = play[1] || {}
          [ play.first, attributes.merge(rebound: rand(5)) ]
        else
          play
        end
      end
    end
  end
end
