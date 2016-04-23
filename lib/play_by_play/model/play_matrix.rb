module PlayByPlay
  module Model
    class PlayMatrix
      ACCESSIBLE_PLAYS = {
        { technical_free_throws: true } => [
            [ :ft ],
            [ :ft_miss ],
            [ :period_end ],
            [ :technical_foul, team: :defense ],
            [ :technical_foul, team: :offense ],
            [ :technical_foul, flagarant: true, team: :defense ],
            [ :technical_foul, flagarant: true, team: :offense ],
          ],
        { free_throws: true } => [
            [ :ft ],
            [ :ft_miss ],
            [ :offensive_foul ],
            [ :period_end ],
            [ :personal_foul, team: :defense ],
            [ :personal_foul, team: :offense ],
            [ :technical_foul, team: :defense ],
            [ :technical_foul, team: :offense ],
            [ :technical_foul, flagarant: true, team: :defense ],
            [ :technical_foul, flagarant: true, team: :offense ],
            [ :turnover ],
          ],
        { team: true } => [
            [ :block ],
            [ :block, point_value: 3 ],
            [ :fg ],
            [ :fg, and_one: true ],
            [ :fg, point_value: 3 ],
            [ :fg, point_value: 3, and_one: true ],
            [ :fg, assisted: true ],
            [ :fg, and_one: true, assisted: true ],
            [ :fg, point_value: 3, assisted: true ],
            [ :fg, point_value: 3, and_one: true, assisted: true ],
            [ :fg_miss ],
            [ :fg_miss, point_value: 3 ],
            [ :jump_ball ],
            [ :jump_ball, team: :defense ],
            [ :jump_ball, team: :offense ],
            [ :jump_ball_out_of_bounds, team: :defense ],
            [ :jump_ball_out_of_bounds, team: :offense ],
            [ :offensive_foul ],
            [ :period_end ],
            [ :personal_foul, away_from_play: true, team: :defense ],
            [ :personal_foul, away_from_play: true, team: :offense ],
            [ :personal_foul, clear_path: true, team: :defense ],
            [ :personal_foul, intentional: true, team: :defense ],
            [ :personal_foul, team: :defense ],
            [ :personal_foul, team: :offense ],
            [ :shooting_foul ],
            [ :shooting_foul, point_value: 3 ],
            [ :steal ],
            [ :technical_foul, team: :defense ],
            [ :technical_foul, team: :offense ],
            [ :technical_foul, flagarant: true, team: :defense ],
            [ :technical_foul, flagarant: true, team: :offense ],
            [ :turnover ],
          ],
        { ball_in_play: true } => [
            [ :jump_ball ],
            [ :jump_ball, team: :defense ],
            [ :jump_ball, team: :offense ],
            [ :jump_ball_out_of_bounds, team: :defense ],
            [ :jump_ball_out_of_bounds, team: :offense ],
            [ :offensive_foul ],
            [ :period_end ],
            [ :personal_foul, clear_path: true, team: :defense ],
            [ :personal_foul, intentional: true, team: :defense ],
            [ :personal_foul, team: :defense ],
            [ :personal_foul, team: :offense ],
            [ :rebound, team: :defense ],
            [ :rebound, team: :offense ],
            [ :team_rebound, team: :defense ],
            [ :team_rebound, team: :offense ],
            [ :technical_foul, team: :defense ],
            [ :technical_foul, team: :offense ],
            [ :technical_foul, flagarant: true, team: :defense ],
            [ :technical_foul, flagarant: true, team: :offense ],
          ],
        { seconds_remaining: false } => [
          [ :period_end ],
        ],
        {} => [
            [ :jump_ball, team: :home ],
            [ :jump_ball, team: :visitor ],
            [ :jump_ball_out_of_bounds, team: :home ],
            [ :jump_ball_out_of_bounds, team: :visitor ],
            [ :period_end ],
            [ :team_rebound, team: :home ],
            [ :team_rebound, team: :visitor ],
            [ :technical_foul, team: :home ],
            [ :technical_foul, team: :visitor ],
            [ :technical_foul, flagarant: true, team: :defense ],
            [ :technical_foul, flagarant: true, team: :offense ],
            [ :turnover, team: :home ],
            [ :turnover, team: :visitor ],
          ]
      }.freeze

      def self.game_key?(key)
        game_keys.include? key
      end

      def self.game_keys
        ACCESSIBLE_PLAYS.keys
      end

      def self.next_plays(possession_key)
        ACCESSIBLE_PLAYS[possession_key]
      end

      def self.next?(possession, play)
        next_plays(possession.key).include? play.key
      end
    end
  end
end
