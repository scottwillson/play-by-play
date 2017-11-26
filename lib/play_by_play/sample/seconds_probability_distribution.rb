require "play_by_play/model/invalid_state_error"
require "play_by_play/model/play_matrix"
require "play_by_play/sample/seconds_probability"

module PlayByPlay
  module Sample
    class SecondsProbabilityDistribution
      def initialize(repository = nil)
        @repository = repository
        @distribution = Hash.new do |hash, key|
          hash[key] = fetch_distribution(key)
        end
      end

      def for(possession)
        raise(ArgumentError, "play is nil for possession #{possession}") unless possession.play

        if possession.offense
          @distribution[Key.new_from_possession(possession, :offense)] + @distribution[Key.new_from_possession(possession, :defense)]
        else
          @distribution[Key.new_from_possession(possession, :home)] + @distribution[Key.new_from_possession(possession, :visitor)]
        end
      end

      def fetch_distribution(key)
        @repository.plays.seconds_counts(key.play_key, key.team, key.team_id).map do |seconds_count|
          SecondsProbability.new seconds_count[:count], seconds_count[:seconds]
        end
      end

      def pre_fetch!
        PlayByPlay.logger.debug(seconds_probability_distribution: :pre_fetch!, begin: Time.now)

        team_ids = @repository.teams.all.map { |team| team[:id] }
        Model::PlayMatrix.play_keys.each do |play_key|
          %i[ defense offense ].each do |team|
            team_ids.each do |team_id|
              @distribution[Key.new(play_key, team, team_id)]
            end
          end

          %i[ home visitor ].each do |team|
            team_ids.each do |team_id|
              @distribution[Key.new(play_key, team, team_id)]
            end
          end
        end

        PlayByPlay.logger.debug(seconds_probability_distribution: :pre_fetch!, end: Time.now)
      end

      class Key
        attr_reader :play_key
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

          new possession.play.key, team, team_id
        end

        def initialize(play_key, team, team_id)
          @play_key = play_key
          @team = team
          @team_id = team_id

          if @team_id.nil?
            raise Model::InvalidStateError, "team_id nil for team #{team} in #{play_key}"
          end
        end

        def ==(other)
          self.class == other&.class && other.values == values
        end

        alias eql? ==

        def values
          [
            play_key,
            team,
            team_id
          ]
        end

        def hash
          @hash ||= values.hash
        end

        def to_s
          {
            play_key: play_key,
            team: team,
            team_id: team_id
          }
        end
      end
    end
  end
end
