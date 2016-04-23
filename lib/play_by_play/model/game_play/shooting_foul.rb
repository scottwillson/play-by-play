module PlayByPlay
  module Model
    module GamePlay
      def self.shooting_foul(possession, play)
        { ball_in_play: false, free_throws: [ possession.offense ] * play.point_value, team: :offense }
          .merge(increment_period_personal_fouls(possession, :defense))
      end
    end
  end
end
