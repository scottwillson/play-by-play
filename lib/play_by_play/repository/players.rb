require "play_by_play/persistent/player"
require "play_by_play/repository/base"

module PlayByPlay
  module RepositoryModule
    class Players < Base
      def find(id)
        return unless id

        attributes = @db[:players].where(id: id).first

        if attributes
          Persistent::Player.new(attributes)
        end
      end

      def save(player)
        if player.nba_id
          attributes = @db[:players].where(nba_id: player.nba_id).first

          if attributes
            player.id = attributes[:id]
            return
          end
        end

        player.id = @db[:players].insert(
          name: player.name,
          nba_id: player.nba_id,
          team_id: player.team_id
        )
      end
    end
  end
end
