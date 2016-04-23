module PlayByPlay
  module Model
    module GamePlay
      def self.fg(possession, play)
        attributes = { ball_in_play: false, team: :defense }
                     .merge(add_points(possession, play.point_value || 2))

        if play.and_one?
          attributes = attributes
                       .merge(ball_in_play: false, free_throws: [ possession.offense ], team: :offense)
                       .merge(increment_period_personal_fouls(possession, :defense))
        end

        attributes
      end
    end
  end
end
