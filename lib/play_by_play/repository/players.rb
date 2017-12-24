require "play_by_play/repository/base"

module PlayByPlay
  module RepositoryModule
    class Players < Base
      def save(player)
        attributes = @db[:players].where(nba_id: player.nba_id).first

        if attributes
          player.id = attributes[:id]
          return
        end

        player.id = @db[:players].insert(
          name: player.name,
          nba_id: player.nba_id
        )
      end
    end
  end
end
