require "play_by_play/persistent/play"

module PlayByPlay
  module Mock
    class Repository
      def initialize
        plays.save({} => [ :jump_ball, team: :visitor ])
        plays.save({ team: :visitor } => [ :fg ])
        plays.save({ team: :visitor } => [ :fg ])
        plays.save({ team: :visitor } => [ :fg, point_value: 3 ])
        plays.save({ team: :home } => [ :fg_miss ])
        plays.save({ team: :visitor } => [ :fg_miss ])
        plays.save({ team: :home } => [ :fg_miss ])
        plays.save({ team: :visitor } => [ :fg_miss ])
        plays.save({ team: :visitor } => [ :steal ])
        plays.save({ ball_in_play: true } => [ :rebound, team: :offense ])
        plays.save({ ball_in_play: true } => [ :rebound, team: :defense ])
        plays.save({ ball_in_play: true } => [ :rebound, team: :defense ])
        plays.save({ ball_in_play: true } => [ :rebound, team: :defense ])
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
          sample_plays.count { |a| a.possession_key == possession_key && a.key == play }
        end

        def save(hash)
          sample_plays << Persistent::Play.from_hash(hash)
        end
      end
    end
  end
end
