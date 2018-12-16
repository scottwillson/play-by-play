require "play_by_play/model/invalid_state_error"
require "play_by_play/model/play"
require "play_by_play/sample/play_probability"

module PlayByPlay
  module Sample
    class PlayProbabilityDistribution
      def initialize(repository = nil)
        @repository = repository
        @distribution = Hash.new do |hash, key|
          hash[key] = fetch_distribution(key)
        end
      end

      def for(possession)
        if possession.period_can_end?
          if possession.seconds_remaining.zero?
            [ PlayProbability.new(1, Model::Play.new(:period_end)) ]
          elsif possession.offense
            @distribution[Key.new_from_possession(possession, :offense)] +
              weight(@distribution[Key.new_from_possession(possession, :defense)], 0.5)
          else
            @distribution[Key.new_from_possession(possession, :home)] +
              @distribution[Key.new_from_possession(possession, :visitor)]
          end
        elsif possession.offense
          (@distribution[Key.new_from_possession(possession, :offense)] +
            weight(@distribution[Key.new_from_possession(possession, :defense)], 0.5))
            .reject { |ap| ap.play.period_end? }
        else
          (@distribution[Key.new_from_possession(possession, :home)] +
            @distribution[Key.new_from_possession(possession, :visitor)])
            .reject { |ap| ap.play.period_end? }
        end
      end

      def fetch_distribution(key)
        # puts "=== #{key.to_s} ==="
        distribution = Model::PlayMatrix.accessible_plays(key.possession_key).map do |play|
          count = @repository.plays.count(key.possession_key, key.team, key.team_id, key.location, play)
          # puts "#{count} #{play}"
          PlayProbability.new count, Model::Play.new(play.first, *play[1..-1])
        end

        map_to_percentages distribution
      end

      # ensure equal weights when comparing distributions
      def map_to_percentages(distribution)
        total = distribution.map(&:probability).sum
        return distribution if total == 0
        distribution.map do |play_probability|
          probability = play_probability.probability.to_f / total
          PlayProbability.new(probability, play_probability.play)
        end
      end

      def pre_fetch!
        PlayByPlay.logger.debug(play_probability_distribution: :pre_fetch!, begin: Time.now)

        team_ids = @repository.teams.all.map { |team| team[:id] }
        %i[ ball_in_play free_throws team technical_free_throws ].each do |possession_key|
          %i[ defense offense ].each do |team|
            %i[ home visitor ].each do |location|
              team_ids.each do |team_id|
                @distribution[Key.new(possession_key, team, team_id, location)]
              end
            end
          end
        end

        %i[ home visitor ].each do |location|
          %i[ home visitor ].each do |team|
            team_ids.each do |team_id|
              @distribution[Key.new(nil, team, team_id, location)]
            end
          end
        end

        PlayByPlay.logger.debug(play_probability_distribution: :pre_fetch!, end: Time.now)
      end

      def weight(distribution, weight)
        distribution
        distribution.map do |play_probability|
          probability = play_probability.probability * weight
          PlayProbability.new(probability, play_probability.play)
        end
      end

      class Key
        attr_reader :location
        attr_reader :possession_key
        attr_reader :team
        attr_reader :team_id

        def self.new_from_possession(possession, team)
          if possession.nil?
            raise ArgumentError, "possession nil for team #{team}"
          end

          team_id = case team
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

          if team_id.nil?
            raise Model::InvalidStateError, "team_id nil for team #{team} in #{possession}"
          end

          location = :home
          if team_id == possession.visitor_id
            location = :visitor
          end

          new possession.key, team, team_id, location
        end

        def initialize(possession_key, team, team_id, location)
          @location = location
          @possession_key = possession_key
          @team = team
          @team_id = team_id

          if @team_id.nil?
            raise Model::InvalidStateError, "team_id nil for team #{team} in #{possession_key} for #{location}"
          end
        end

        def ==(other)
          self.class == other&.class && other.values == values
        end

        alias eql? ==

        def values
          [
            location,
            possession_key,
            team,
            team_id
          ]
        end

        def hash
          @hash ||= values.hash
        end

        def to_s
          {
            location: location,
            possession_key: possession_key,
            team: team,
            team_id: team_id
          }
        end
      end
    end
  end
end
