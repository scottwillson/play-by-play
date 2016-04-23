module PlayByPlay
  module Model
    module GamePlay
      def self.jump_ball_out_of_bounds(_, play)
        { ball_in_play: false, team: play.team }
      end
    end
  end
end
