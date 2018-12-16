require "text-table"

module PlayByPlay
  module Views
    class Teams
      def initialize(season)
        @season = season
      end

      def assists(team)
        possessions(team).select do |possession|
          possession.offense_id == team.id && possession.play.assisted?
        end.size
      end

      def average(numerator, denominator)
        if denominator.zero?
          "0.0"
        else
          format "%.1f", (numerator / denominator.to_f)
        end
      end

      def blocks(team)
        possessions(team).select do |possession|
          possession.defense_id == team.id && possession.play.type == :block
        end.size
      end

      def fg(team)
        possessions(team).select do |possession|
          possession.offense_id == team.id && possession.play.type == :fg
        end.size
      end

      def fg3(team)
        possessions(team).select do |possession|
          possession.offense_id == team.id && possession.play.type == :fg && possession.play.point_value == 3
        end.size
      end

      def ft(team)
        possessions(team).select do |possession|
          possession.offense_id == team.id && possession.play.type == :ft
        end.size
      end

      def opp_fg(team)
        possessions(team).select do |possession|
          possession.defense_id == team.id && possession.play.type == :fg
        end.size
      end

      def percentage(made, attempts)
        return 0 if attempts.zero?
        (made / attempts.to_f) * 100
      end

      def fga(team)
        possessions(team).select do |possession|
          possession.offense_id == team.id && (possession.play.type == :fg || possession.play.type == :block || possession.play.type == :fg_miss)
        end.size
      end

      def fg3a(team)
        possessions(team).select do |possession|
          possession.offense_id == team.id &&
            (possession.play.type == :fg || possession.play.type == :block || possession.play.type == :fg_miss) &&
            possession.play.point_value == 3
        end.size
      end

      def fta(team)
        possessions(team).select do |possession|
          possession.offense_id == team.id && (possession.play.type == :ft || possession.play.type == :ft_miss)
        end.size
      end

      def opp_fga(team)
        possessions(team).select do |possession|
          possession.defense_id == team.id && (possession.play.type == :fg || possession.play.type == :block || possession.play.type == :fg_miss)
        end.size
      end

      def games(team)
        team.games.select(&:over?)
      end

      def games_count(team)
        games(team).size
      end

      def opp_points(team)
        possessions(team)
          .select { |possession| possession.defense_id == team.id }
          .inject(0) do |total, possession|
          case possession.play&.type
          when :fg
            total + (possession.play.point_value || 2)
          when :ft
            total + 1
          else
            total
          end
        end
      end

      def points(team)
        possessions(team)
          .select { |possession| possession.offense_id == team.id }
          .inject(0) do |total, possession|
          case possession.play&.type
          when :fg
            total + (possession.play.point_value || 2)
          when :ft
            total + 1
          else
            total
          end
        end
      end

      def possessions(team)
        games(team).map(&:possessions).flatten.select(&:play)
      end

      def steals(team)
        possessions(team).select do |possession|
          possession.offense_id == team.id && possession.play.type == :steal
        end.size
      end

      def defensive_rebounds(team)
        possessions(team).select do |possession|
          possession.offense_id == team.id && (possession.play.type == :rebound || possession.play.type == :team_rebound) && possession.play.team == :defense
        end.size
      end

      def offensive_rebounds(team)
        possessions(team).select do |possession|
          possession.offense_id == team.id && (possession.play.type == :rebound || possession.play.type == :team_rebound) && possession.play.team == :offense
        end.size
      end

      def opp_rebounds(team)
        possessions(team).select do |possession|
          (possession.defense_id == team.id && (possession.play.type == :rebound || possession.play.type == :team_rebound) && possession.play.team == :offense) ||
            (possession.offense_id == team.id && (possession.play.type == :rebound || possession.play.type == :team_rebound) && possession.play.team == :defense)
        end.size
      end

      def personal_fouls(team)
        possessions(team).select do |possession|
          (possession.defense_id == team.id && (possession.play.type == :personal_foul || possession.play.type == :shooting_foul)) ||
            (possession.offense_id == team.id && possession.play.type == :offensive_foul)
        end.size
      end

      def turnovers(team)
        possessions(team).select do |possession|
          (possession.defense_id == team.id && possession.play.type == :steal) ||
            (possession.offense_id == team.id && possession.play.type == :turnover)
        end.size
      end

      def losses(team)
        team.games.select { |game| game.loser == team }.size
      end

      def wins(team)
        team.games.select { |game| game.winner == team }.size
      end

      def team_line(team)
        fg = fg(team)
        fga = fga(team)
        fg_percentage = format "%.1f", percentage(fg, fga)
        ft = ft(team)
        fta = fta(team)
        ft_percentage = format "%.1f", percentage(ft, fta)
        fg3 = fg3(team)
        fg3a = fg3a(team)
        fg3_percentage = format "%.1f", percentage(fg3, fg3a)
        games_count = games_count(team)
        points = points(team)
        opp_points = opp_points(team)
        points_diff = points - opp_points
        offensive_rebounds = offensive_rebounds(team)
        defensive_rebounds = defensive_rebounds(team)
        rebounds = offensive_rebounds + defensive_rebounds
        assists = assists(team)
        turnovers = turnovers(team)
        steals = steals(team)
        blocks = blocks(team)
        personal_fouls = personal_fouls(team)

        [
          team.name,
          wins(team),
          losses(team),
          { value: average(fg, games_count), align: :right },
          { value: average(fga, games_count), align: :right },
          { value: fg_percentage, align: :right },
          { value: average(fg3, games_count), align: :right },
          { value: average(fg3a, games_count), align: :right },
          { value: fg3_percentage, align: :right },
          { value: average(ft, games_count), align: :right },
          { value: average(fta, games_count), align: :right },
          { value: ft_percentage, align: :right },
          { value: average(offensive_rebounds, games_count), align: :right },
          { value: average(defensive_rebounds, games_count), align: :right },
          { value: average(rebounds, games_count), align: :right },
          { value: average(assists, games_count), align: :right },
          { value: average(turnovers, games_count), align: :right },
          { value: average(steals, games_count), align: :right },
          { value: average(blocks, games_count), align: :right },
          { value: average(personal_fouls, games_count), align: :right },
          { value: average(points, games_count), align: :right },
          { value: average(opp_points, games_count), align: :right },
          { value: average(points_diff, games_count), align: :right }
        ]
      end

      def opoonent_team_line(team)
        games_count = games_count(team)
        opp_fg = opp_fg(team)
        opp_fga = opp_fga(team)
        opponent_fg_percentage = format "%.1f", percentage(opp_fg, opp_fga)
        opp_rebounds = opp_rebounds(team)

        [
          team.name,
          { value: opponent_fg_percentage, align: :right },
          { value: average(opp_rebounds, games_count), align: :right }
        ]
      end

      def to_s
        team_table = Text::Table.new(first_row_is_head: true)
        team_table.head = %w[name w l fg fga fg% 3fg 3fga 3fg% ft fta ft% oreb dreb reb ast to stl blk pf points opp_points diff]
        team_table.rows = @season.teams.sort_by { |team| wins(team) }.map { |team| team_line(team) }

        opponent_table = Text::Table.new(first_row_is_head: true)
        opponent_table.head = %w[name opp_fg% opp_reb]
        opponent_table.rows = @season.teams.sort_by(&:name).map { |team| opoonent_team_line(team) }

        team_table.to_s + "\n" + opponent_table.to_s
      end
    end
  end
end
