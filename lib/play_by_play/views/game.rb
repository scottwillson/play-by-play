module PlayByPlay
  module Views
    class Game
      def initialize(game)
        @game = game
      end

      def team_text(team)
        team.abbreviation
      end

      def to_s
        "#{team_text(@game.visitor)} #{@game.possession.visitor.points}\n#{team_text(@game.home)} #{@game.possession.home.points}\n"
      end
    end
  end
end
