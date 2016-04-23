require "play_by_play/sample/play_probability"
require "play_by_play/model/play"

module PlayByPlay
  module Sample
    class PlayProbabilityDistribution
      attr_accessor :play_probability_distribution

      def initialize(repository = nil)
        @repository = repository
        @play_probability_distribution = Hash.new { |hash, possession_key| hash[possession_key] = fetch_play_probability_distribution(possession_key) }
      end

      def for(possession)
        return [ PlayProbability.new(1, [ :period_end ]) ] if possession.seconds_remaining == 0

        if possession.seconds_remaining < 24
          play_probability_distribution[possession.key]
        else
          play_probability_distribution[possession.key].reject { |ap| ap.play == [ :period_end ] }
        end
      end

      def fetch_play_probability_distribution(possession_key)
        puts("====== #{possession_key} =====") if debug?
        Model::PlayMatrix::next_plays(possession_key).map do |play|
          count = @repository.count_plays(possession_key, play)
          puts("#{count}   #{play}") if debug?
          PlayProbability.new(count, play)
        end
      end

      def debug?
        ENV["DEBUG"]
      end
    end
  end
end
