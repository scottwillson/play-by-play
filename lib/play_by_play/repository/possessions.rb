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
          home_margin: possession.home_margin,
          next_team: possession.next_team.to_s,
          offense: possession.offense.to_s,
          offense_id: possession.offense_id,
          opening_tip: possession.opening_tip.to_s,
          period: possession.period,
          seconds_remaining: possession.seconds_remaining,
          source: possession.game.source,
          team: possession.team?,
          technical_free_throws: possession.technical_free_throws?,
          visitor_id: possession.game.visitor_id,
          visitor_margin: possession.visitor_margin
        }

        play = possession.play
        if play
          attributes = attributes.merge(
            play_team: play.team.to_s,
            and_one: play.and_one?,
            assisted: play.assisted?,
            away_from_play: play.away_from_play?,
            clear_path: play.clear_path?,
            flagrant: play.flagrant?,
            intentional: play.intentional?,
            opponent_id: play.opponent_id,
            play_type: play.type.to_s,
            player_id: play.player_id,
            seconds: play.seconds,
            teammate_id: play.teammate_id
          )

          if play.point_value == 3
            attributes = attributes.merge(point_value: 3)
          end
        end

        possession.id = @db[:possessions].insert(attributes)

        if play
          repository.rows.update play.row, possession.id
        end

        possession
      end
    end
  end
end
