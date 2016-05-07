require "play_by_play/persistent/play"

module PlayByPlay
  module Mock
    class Repository
      attr_reader :sample_plays

      def initialize
        @sample_plays = []
        save_play({} => [ :jump_ball, team: :visitor ])
        save_play({ team: :visitor } => [ :fg ])
        save_play({ team: :visitor } => [ :fg ])
        save_play({ team: :visitor } => [ :fg, point_value: 3 ])
        save_play({ team: :home } => [ :fg_miss ])
        save_play({ team: :visitor } => [ :fg_miss ])
        save_play({ team: :home } => [ :fg_miss ])
        save_play({ team: :visitor } => [ :fg_miss ])
        save_play({ team: :visitor } => [ :steal ])
        save_play({ ball_in_play: true } => [ :rebound, team: :offense ])
        save_play({ ball_in_play: true } => [ :rebound, team: :defense ])
        save_play({ ball_in_play: true } => [ :rebound, team: :defense ])
        save_play({ ball_in_play: true } => [ :rebound, team: :defense ])
      end

      def count_plays(possession_key, play)
        sample_plays.count { |a| a.possession_key == possession_key && a.key == play }
      end

      def save_play(hash)
        sample_plays << Persistent::Play.from_hash(hash)
      end

      def reset!
        @sample_plays = []
      end
    end
  end
end
