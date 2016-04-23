module PlayByPlay
  module Model
    module GamePlay
      def self.ft(possession, _)
        attributes = decrement_free_throws(possession)
                     .merge(add_points(possession, 1))

        if possession.last_free_throw? && possession.technical_free_throws?
          attributes.merge(ball_in_play: false, team: possession.technical_free_throws.last)

        elsif possession.last_free_throw? && possession.next_team
          attributes.merge(ball_in_play: false, next_team: nil, team: possession.next_team)

        elsif possession.last_free_throw?
          attributes.merge(team: possession.other_team(possession.free_throws.first))

        elsif possession.last_technical_free_throw? && possession.free_throws?
          attributes.merge(ball_in_play: false, team: possession.free_throws.last)

        elsif possession.last_technical_free_throw? && !possession.free_throws?
          attributes.merge(ball_in_play: false, next_team: nil, team: possession.next_team)

        else
          attributes
        end
      end
    end
  end
end
