module PlayByPlay
  module Model
    module GamePlay
      def self.rebound(_, play)
        { team: play.team }
      end
    end
  end
end
