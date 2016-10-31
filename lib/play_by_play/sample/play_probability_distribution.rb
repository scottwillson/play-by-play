require "play_by_play/sample/play_probability"
require "play_by_play/model/play"

module PlayByPlay
  module Sample
    class PlayProbabilityDistribution
      attr_accessor :play_probability_distribution

      def initialize(repository = nil)
        @repository = repository
        @play_probability_distribution = Hash.new do |hash, key|
          hash[key] = fetch_play_probability_distribution(key)
        end
      end

      def for(possession)
        if possession.seconds_remaining > 24 || possession.free_throws? || possession.technical_free_throws?
          play_probability_distribution[Key.new(possession)].reject { |ap| ap.play == [ :period_end ] }
        elsif possession.seconds_remaining.zero?
          [ PlayProbability.new(1, [ :period_end ]) ]
        else
          play_probability_distribution[Key.new(possession)]
        end
      end

      def fetch_play_probability_distribution(key)
        # puts "=== #{key.to_s} ==="
        Model::PlayMatrix.accessible_plays(key.possession.key).map do |play|
          count = @repository.plays.count(key.possession, key.defense_id, key.home_id, key.offense_id, key.visitor_id, play)
          # puts "#{count} #{play}"
          PlayProbability.new count, play
        end
      end

      class Key
        attr_reader :defense_id
        attr_reader :home_id
        attr_reader :offense_id
        attr_reader :possession
        attr_reader :visitor_id

        def initialize(possession)
          @defense_id = possession.defense_id
          @home_id = possession.home_id
          @offense_id = possession.offense_id
          @possession = possession
          @visitor_id = possession.visitor_id
        end

        def ==(other)
          self.class == other&.class && other.values == values
        end

        alias eql? ==

        def values
          [
            possession.defense_id,
            possession.home_id,
            possession.offense_id,
            possession.key,
            possession.visitor_id
          ]
        end

        def hash
          @hash ||= values.hash
        end

        def to_s
          {
            defense_id: possession.defense_id,
            home_id: possession.home_id,
            offense_id: possession.offense_id,
            possession_key: possession.key,
            visitor_id: possession.visitor_id
          }
        end
      end
    end
  end
end
