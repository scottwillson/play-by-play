module PlayByPlay
  module Model
    module GamePlay
      def self.block(possession, play)
        { ball_in_play: true, team: nil }
      end
    end
  end
end
