module PlayByPlay
  module Model
    module GamePlay
      def self.team_rebound(_, play)
        { team: play.team }
      end
    end
  end
end
