module PlayByPlay
  module Model
    module GamePlay
      def self.personal_foul(possession, play)
        attributes = { ball_in_play: false }.merge(increment_period_personal_fouls(possession, play.team))
        other_team = possession.other_team(play.team)

        if play.away_from_play?
          attributes.merge(free_throws: [ other_team ], team: other_team)

        elsif play.intentional?
          attributes.merge(free_throws: [ other_team ] * 2, team: other_team)

        elsif play.clear_path?
          attributes.merge(free_throws: [ other_team ] * 2, team: other_team, next_team: other_team)

        elsif next_foul_in_penalty?(possession, play.team)
          attributes.merge(free_throws: [ other_team ] * 2, team: other_team)

        elsif play.team == :offense
          attributes.merge(free_throws: [ other_team ], team: other_team)

        else
          attributes.merge(team: other_team)
        end
      end

      def self.next_foul_in_penalty?(possession, team)
        team = possession.team_instance(team)
        team.period_personal_fouls >= 4 || team.personal_foul_in_last_two_minutes
      end
    end
  end
end
