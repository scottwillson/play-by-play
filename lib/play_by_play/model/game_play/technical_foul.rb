module PlayByPlay
  module Model
    module GamePlay
      def self.technical_foul(possession, play)
        new_fts = add_technical_free_throws(possession, play)

        attributes = {
          ball_in_play: false,
          offense: possession.other_team(play.team),
          technical_free_throws: new_fts,
          team: new_fts.last
        }

        if possession.pending_free_throws?
          attributes
        elsif play.flagrant?
          attributes.merge(next_team: possession.other_team(play.team))
        else
          attributes.merge(next_team: possession.team)
        end
      end
    end
  end
end
