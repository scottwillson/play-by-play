require "play_by_play/repository/base"

module PlayByPlay
  module RepositoryModule
    class Possessions < Base
      def save(possession)
        possession.id = @db[:possessions].insert(
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
          team: possession.team?,
          technical_free_throws: possession.technical_free_throws?,
          visitor_id: possession.game.visitor_id
        )
      end

      def update(possession, play_id)
        return unless possession && play_id
        @db[:possessions].where(id: possession.id).update(play_id: play_id)
        true
      end
    end
  end
end
