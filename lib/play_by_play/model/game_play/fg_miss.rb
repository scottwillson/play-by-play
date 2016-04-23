module PlayByPlay
  module Model
    module GamePlay
      def self.fg_miss(_, _)
        { ball_in_play: true, team: nil }
      end
    end
  end
end
