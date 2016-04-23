module PlayByPlay
  module Model
    module GamePlay
      def self.offensive_foul(_, _)
        { ball_in_play: false, free_throws: [], team: :defense }
      end
    end
  end
end
