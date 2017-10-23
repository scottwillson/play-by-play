require "play_by_play/repository/base"

module PlayByPlay
  module RepositoryModule
    class Possessions < Base
      def save(possession)
        attributes = {
          ball_in_play: possession.ball_in_play?,
          defense_id: possession.defense_id,
          free_throws: possession.free_throws?,
          game_id: possession.game_id,
          home_id: possession.game.home_id,
          next_team: possession.next_team.to_s,
          offense: possession.offense.to_s,
          offense_id: possession.offense_id,
          opening_tip: possession.opening_tip.to_s,
          period: possession.period,
          seconds_remaining: possession.seconds_remaining,
          source: possession.game.source,
          team: possession.team?,
          technical_free_throws: possession.technical_free_throws?,
          visitor_id: possession.game.visitor_id
        }

        if possession.play
          attributes = attributes.merge(
            play_team: possession.play.team.to_s,
            and_one: possession.play.and_one?,
            assisted: possession.play.assisted?,
            away_from_play: possession.play.away_from_play?,
            clear_path: possession.play.clear_path?,
            flagrant: possession.play.flagrant?,
            intentional: possession.play.intentional?,
            play_type: possession.play.type.to_s
          )

          if possession.play.point_value == 3
            attributes = attributes.merge(point_value: 3)
          end
        end

        possession.id = @db[:possessions].insert(attributes)

        if possession.play
          repository.rows.update possession.play.row, possession.id
        end

        possession
      end
    end
  end
end
