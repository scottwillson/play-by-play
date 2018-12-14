require "play_by_play/persistent/play"

module PlayByPlay
  module Mock
    class Repository
      def initialize
        plays.save_hash({} => [ :jump_ball, team: :visitor, seconds: 1 ])
        plays.save_hash({ team: :visitor } => [ :fg, seconds: 19 ])
        plays.save_hash({ team: :visitor } => [ :fg, seconds: 8 ])
        plays.save_hash({ team: :visitor } => [ :fg, point_value: 3, seconds: 12 ])
        plays.save_hash({ team: :home } => [ :fg_miss, seconds: 4 ])
        plays.save_hash({ team: :visitor } => [ :fg_miss, seconds: 18 ])
        plays.save_hash({ team: :home } => [ :fg_miss, seconds: 17 ])
        plays.save_hash({ team: :visitor } => [ :fg_miss, seconds: 11 ])
        plays.save_hash({ team: :visitor } => [ :steal, seconds: 5 ])
        plays.save_hash({ ball_in_play: true } => [ :rebound, team: :offense, seconds: 1 ])
        plays.save_hash({ ball_in_play: true } => [ :rebound, team: :defense, seconds: 2 ])
        plays.save_hash({ ball_in_play: true } => [ :rebound, team: :defense, seconds: 0 ])
        plays.save_hash({ ball_in_play: true } => [ :rebound, team: :defense, seconds: 3 ])
        plays.save_hash({ ball_in_play: true } => [ :period_end, seconds: 9 ])
      end

      def plays
        @plays ||= Plays.new
      end

      def reset!
        plays.sample_plays = []
      end

      class Plays
        attr_accessor :sample_plays

        def initialize
          @sample_plays = []
        end

        def count(possession_key, _, _, _, play)
          sample_plays.count do |a|
            if play.size > 1 && play.last[:team]
              a.possession_key == possession_key && a.key == play && a.team == play.last[:team]
            else
              a.possession_key == possession_key && a.key == play
            end
          end
        end

        def save(play)
          sample_plays << play
        end

        def save_hash(hash)
          possession = Persistent::Possession.new(hash.keys.first)
          play_attributes = hash.values.first.dup
          type = play_attributes.shift
          play_attributes = play_attributes.first || {}

          play = Persistent::Play.new(type, play_attributes.merge(possession: possession))
          sample_plays << play
        end

        # Incorrectly ignore play team
        def seconds_counts(play_key, _, _)
          sample_plays
            .select { |play| play.key == play_key }
            .group_by(&:seconds)
            .map { |count, play| { count: count, seconds: play.first.seconds } }
        end
      end
    end
  end
end
