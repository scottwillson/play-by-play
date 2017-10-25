require "play_by_play/repository/base"

module PlayByPlay
  module RepositoryModule
    class Rows < Base
      def save(rows)
        columns = %i[
          possession_id
          game_id
          eventmsgactiontype
          eventmsgtype
          eventnum
          homedescription
          neutraldescription
          pctimestring
          period
          person1type
          person2type
          person3type
          player1_id
          player1_name
          player1_team_abbreviation
          player1_team_city
          player1_team_id
          player1_team_nickname
          player2_id
          player2_name
          player2_team_abbreviation
          player2_team_city
          player2_team_id
          player2_team_nickname
          player3_id
          player3_name
          player3_team_abbreviation
          player3_team_city
          player3_team_id
          player3_team_nickname
          score
          scoremargin
          visitordescription
          wctimestring
        ]

        values = rows.map do |row|
          [
            row.possession_id,
            row.game.id,
            row.eventmsgactiontype,
            row.eventmsgtype,
            row.eventnum,
            row.homedescription,
            row.neutraldescription,
            row.pctimestring,
            row.period,
            row.person1type,
            row.person2type,
            row.person3type,
            row.player1_id,
            row.player1_name,
            row.player1_team_abbreviation,
            row.player1_team_city,
            row.player1_team_id,
            row.player1_team_nickname,
            row.player2_id,
            row.player2_name,
            row.player2_team_abbreviation,
            row.player2_team_city,
            row.player2_team_id,
            row.player2_team_nickname,
            row.player3_id,
            row.player3_name,
            row.player3_team_abbreviation,
            row.player3_team_city,
            row.player3_team_id,
            row.player3_team_nickname,
            row.score,
            row.scoremargin,
            row.visitordescription,
            row.wctimestring
          ]
        end

        db[:rows].import columns, values
      end

      def update(row, possession_id)
        return unless row && possession_id
        db[:rows].where(id: row.id).update(possession_id: possession_id)
        true
      end
    end
  end
end
