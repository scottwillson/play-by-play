require "play_by_play/persistent/play"

module PlayByPlay
  module Mock
    class Repository
      def initialize
        plays.save({} => [ :jump_ball, team: :visitor, seconds: 1, teammate: 0, player: 0, opponent: 0 ])
        plays.save({ team: :visitor } => [ :fg, seconds: 19, player: 0 ])
        plays.save({ team: :visitor } => [ :fg, seconds: 8, player: 0 ])
        plays.save({ team: :visitor } => [ :fg, point_value: 3, seconds: 12, player: 1 ])
        plays.save({ team: :home } => [ :fg_miss, seconds: 4, player: 4 ])
        plays.save({ team: :visitor } => [ :fg_miss, seconds: 18, player: 0 ])
        plays.save({ team: :home } => [ :fg_miss, seconds: 17, player: 0 ])
        plays.save({ team: :visitor } => [ :fg_miss, seconds: 11, player: 0 ])
        plays.save({ team: :visitor } => [ :steal, seconds: 5, opponent: 0, player: 0 ])
        plays.save({ ball_in_play: true } => [ :rebound, team: :offense, player: 0, seconds: 1 ])
        plays.save({ ball_in_play: true } => [ :rebound, team: :defense, player: 0, seconds: 2 ])
        plays.save({ ball_in_play: true } => [ :rebound, team: :defense, player: 0, seconds: 0 ])
        plays.save({ ball_in_play: true } => [ :rebound, team: :defense, player: 0, seconds: 3 ])
        plays.save({ ball_in_play: true } => [ :period_end, seconds: 9 ])
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

        def count(possession_key, _, _, play)
          sample_plays.count do |a|
            if play.size > 1 && play.last[:team]
              a.possession_key == possession_key && a.key == play && a.team == play.last[:team]
            else
              a.possession_key == possession_key && a.key == play
            end
          end
        end

        def save(hash)
          sample_plays << Persistent::Play.from_hash(hash)
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
