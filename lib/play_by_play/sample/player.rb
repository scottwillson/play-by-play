require "play_by_play/persistent/game"
require "play_by_play/persistent/player"

module PlayByPlay
  module Sample
    module Player
      def self.add_players(game)
        home_players = []
        visitor_players = []

        game.rows.flat_map(&:player_attributes).each do |attributes|
          if attributes[0] == 4
            home_players << Persistent::Player.new(nba_id: attributes[1], name: attributes[2])
          elsif attributes[0] == 5
            visitor_players << Persistent::Player.new(nba_id: attributes[1], name: attributes[2])
          end
        end

        home_players.uniq(&:nba_id).each do |player|
          game.home.players << player
        end

        visitor_players.uniq(&:nba_id).each do |player|
          game.visitor.players << player
        end
      end
    end
  end
end
