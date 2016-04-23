module PlayByPlay
  module Model
    module GamePlay
      def self.jump_ball(_, play)
        { ball_in_play: play.team != nil, team: play.team }
      end
    end
  end
end
