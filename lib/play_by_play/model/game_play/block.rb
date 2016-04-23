module PlayByPlay
  module Model
    module GamePlay
      def self.block(_, _)
        { ball_in_play: true, team: nil }
      end
    end
  end
end
