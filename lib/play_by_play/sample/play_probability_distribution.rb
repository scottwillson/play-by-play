require "play_by_play/model/invalid_state_error"
require "play_by_play/model/play"
require "play_by_play/sample/play_probability"

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
        # TODO rework
        period_can_end = !possession.free_throws? && !possession.technical_free_throws? && possession.seconds_remaining <= 24

        if period_can_end
          if possession.seconds_remaining.zero?
            [ PlayProbability.new(1, [ :period_end ]) ]
          elsif possession.offense
            play_probability_distribution[Key.new(possession, :offense)] + play_probability_distribution[Key.new(possession, :defense)]
          else
            play_probability_distribution[Key.new(possession, :home)] + play_probability_distribution[Key.new(possession, :visitor)]
          end
        elsif possession.offense
          (play_probability_distribution[Key.new(possession, :offense)] + play_probability_distribution[Key.new(possession, :defense)]).reject { |ap| ap.play == [ :period_end ] }
        else
          (play_probability_distribution[Key.new(possession, :home)] + play_probability_distribution[Key.new(possession, :visitor)]).reject { |ap| ap.play == [ :period_end ] }
        end
      end

      def fetch_play_probability_distribution(key)
        # puts "=== #{key.to_s} ==="
        Model::PlayMatrix.accessible_plays(key.possession.key).map do |play|
          count = @repository.plays.count(key.possession, key.team, key.team_id, play)
          # puts "#{count} #{play}"
          PlayProbability.new count, play
        end
      end

      class Key
        attr_reader :possession
        attr_reader :team
        attr_reader :team_id

        def initialize(possession, team)
          @possession = possession
          @team = team

          @team_id = case team
                     when :defense
                       possession.defense_id
                     when :home
                       possession.home_id
                     when :offense
                       possession.offense_id
                     when :visitor
                       possession.visitor_id
                     else
                       raise ArgumentError, "team must be :defense, :home, :offense, or :visitor but was #{team}"
                     end

          if @team_id.nil?
            raise Model::InvalidStateError, "team_id nil for team #{team} in #{possession}"
          end
        end

        def ==(other)
          self.class == other&.class && other.values == values
        end

        alias eql? ==

        def values
          [
            possession.key,
            team,
            team_id
          ]
        end

        def hash
          @hash ||= values.hash
        end

        def to_s
          {
            possession_key: possession.key,
            team: team,
            team_id: team_id
          }
        end
      end
    end
  end
end
