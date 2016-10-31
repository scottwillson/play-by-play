require "play_by_play/repository/base"

module PlayByPlay
  module RepositoryModule
    class Plays < Base
      def count(possession, defense_id, home_id, offense_id, visitor_id, play)
        # p "possession: #{possession}, defense_id: #{defense_id}, home_id: #{home_id}, offense_id: #{offense_id}, visitor_id: #{visitor_id}, play: #{play}"

        raise(ArgumentError, "home_id cannot be nil") unless home_id
        raise(ArgumentError, "visitor_id cannot be nil") unless visitor_id
        raise(ArgumentError, "play cannot be nil") unless play

        raise(ArgumentError, "defense_id cannot be nil") if defense_id.nil? && !offense_id.nil?
        raise(ArgumentError, "offense_id cannot be nil") if offense_id.nil? && !defense_id.nil?

        play_attributes = {}
        if play.size > 1
          play_attributes = play.last.dup
        end

        play_team = play_attributes.delete(:team)

        query = db[:plays]
                .join(:possessions, id: :possession_id)
                .where(
                  and_one:        play_attributes[:and_one] || false,
                  assisted:       play_attributes[:assisted] || false,
                  away_from_play: play_attributes[:away_from_play] || false,
                  clear_path:     play_attributes[:clear_path] || false,
                  flagrant:       play_attributes[:flagrant] || false,
                  intentional:    play_attributes[:intentional] || false,
                  type:           play.first.to_s
                )

        if play_attributes[:point_value]
          query = query.where(point_value: play_attributes[:point_value])
        end

        if play_team
          query = query.where(plays__team: play_team.to_s)
        end

        if possession.technical_free_throws?
          query = query.where(technical_free_throws: true)
        elsif possession.free_throws?
          query = query.where(technical_free_throws: false, free_throws: true)
        elsif possession.team?
          query = query.where(technical_free_throws: false, free_throws: false, possessions__team: true)
        elsif possession.ball_in_play?
          query = query.where(technical_free_throws: false, free_throws: false, possessions__team: false, ball_in_play: true)
        elsif !possession.seconds_remaining?
          query = query.where(technical_free_throws: false, free_throws: false, possessions__team: false, ball_in_play: false, seconds_remaining: 0)
        else
          query = query.where(technical_free_throws: false, free_throws: false, possessions__team: false, ball_in_play: false)
          query = query.where("seconds_remaining > 0")
        end

        if possession.offense
          query = query.where("possessions.defense_id = ? or possessions.offense_id = ?", defense_id, offense_id)
        else
          query = query.where("possessions.home_id = ? or possessions.visitor_id = ?", home_id, visitor_id)
        end

        if play_attributes[:team]
          query = query.where(plays__team: play_attributes[:team].to_s)
        end

        # puts(query.sql) if rand < 0.1

        query.count
      end

      def save_all(plays)
        plays.each { |play| save(play) }
      end

      def save(play)
        attributes = {
          possession_id: play.possession.id,
          team: play.team.to_s,
          and_one: play.and_one?,
          assisted: play.assisted?,
          away_from_play: play.away_from_play?,
          clear_path: play.clear_path?,
          flagrant: play.flagrant?,
          intentional: play.intentional?,
          type: play.type.to_s
        }

        if play.point_value == 3
          attributes = attributes.merge(point_value: 3)
        end

        play.id = db[:plays].insert(attributes)
        repository.rows.update play.row, play.id
      end
    end
  end
end
