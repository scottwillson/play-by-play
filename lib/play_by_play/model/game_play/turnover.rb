module PlayByPlay
  module Model
    module GamePlay
      def self.turnover(possession, play)
        if possession.free_throws? && possession.next_team
          { ball_in_play: false, free_throws: [], next_team: nil, team: possession.next_team }
        elsif play.team
          { ball_in_play: false, free_throws: [], team: possession.other_team }
        else
          { ball_in_play: false, free_throws: [], team: possession.other_team }
        end
      end
    end
  end
end
