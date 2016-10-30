module PlayByPlay
  module Model
    module GamePlay
      def self.ft_miss(possession, _)
        attributes = decrement_free_throws(possession)

        if possession.last_free_throw? && possession.next_team
          attributes.merge(next_team: nil, team: possession.next_team)

        elsif possession.last_technical_free_throw? && possession.free_throws?
          attributes.merge(team: possession.free_throws.last)

        elsif possession.last_technical_free_throw? && !possession.free_throws?
          attributes.merge(next_team: nil, team: possession.next_team)

        elsif attributes[:technical_free_throws]
          attributes.merge(team: attributes[:technical_free_throws].last)

        elsif possession.last_free_throw?
          attributes.merge(ball_in_play: true, next_team: nil, team: nil)

        else
          attributes
        end
      end
    end
  end
end
