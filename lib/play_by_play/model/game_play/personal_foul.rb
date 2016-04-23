module PlayByPlay
  module Model
    module GamePlay
      def self.personal_foul(possession, play)
        attributes = { ball_in_play: false }.merge(increment_period_personal_fouls(possession, play.team))
        other_team = possession.to_visitor_or_home_symbol(possession.other_team(play.team))

        if play.away_from_play?
          attributes = attributes.merge(free_throws: [ other_team ], team: other_team)

        elsif play.intentional?
          attributes = attributes.merge(free_throws: [ other_team ] * 2, team: other_team)

        elsif play.clear_path?
          attributes = attributes.merge(free_throws: [ other_team ] * 2, team: other_team, next_team: other_team)

        elsif possession.team_instance(play.team).next_foul_in_penalty?
          attributes = attributes.merge(free_throws: [ other_team ] * 2, team: other_team)

        elsif play.team == :offense
          attributes.merge(free_throws: [ other_team ], team: other_team)

        else
          attributes.merge(team: other_team)
        end
      end
    end
  end
end
