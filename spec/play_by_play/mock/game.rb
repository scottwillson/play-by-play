require "play_by_play/persistent/play"
require "play_by_play/sample/game"

module PlayByPlay
  module Mock
    class Game
      def self.new_persistent(nba_id = "0021400014", home_abbreviation = "CLE", visitor_abbreviation = "GSW")
        game = PlayByPlay::Sample::Game.new_game(nba_id, home_abbreviation, visitor_abbreviation)

        13.times do |index|
          game.home.players << Persistent::Player.new(name: "Home Player #{index}")
          game.visitor.players << Persistent::Player.new(name: "Visitor Player #{index}")
        end

        game
      end
    end
  end
end
