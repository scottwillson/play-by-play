require "play_by_play/repository/base"

module PlayByPlay
  module RepositoryModule
    class Plays < Base
      PLAY_KEYS = %i[and_one assisted away_from_play clear_path flagrant intentional point_value].freeze

      def count(possession_key, team, team_id, location, play)
        raise(ArgumentError, "location cannot be nil") unless location
        raise(ArgumentError, "play cannot be nil") unless play
        raise(ArgumentError, "team cannot be nil") unless team
        raise(ArgumentError, "team_id cannot be nil") unless team_id
        raise(ArgumentError, "possession_key must be nil or a symbol, but was #{possession_key}") unless possession_key.nil? || possession_key.is_a?(Symbol)

        play_attributes = {}
        if play.size > 1
          play_attributes = play.last.dup
        end

        query = db[:possessions]
                .where(
                  and_one:        play_attributes[:and_one] || false,
                  assisted:       play_attributes[:assisted] || false,
                  away_from_play: play_attributes[:away_from_play] || false,
                  clear_path:     play_attributes[:clear_path] || false,
                  flagrant:       play_attributes[:flagrant] || false,
                  intentional:    play_attributes[:intentional] || false,
                  point_value:    play_attributes[:point_value],
                  play_type:      play.first.to_s
                )

        if play_attributes[:point_value]
          query = query.where(point_value: play_attributes[:point_value])
        end

        play_team = play_attributes.delete(:team)
        if play_team
          query = query.where(play_team: play_team.to_s)
        end

        case possession_key
        when :technical_free_throws
          query = query.where(technical_free_throws: true)
        when :free_throws
          query = query.where(technical_free_throws: false, free_throws: true)
        when :team
          query = query.where(technical_free_throws: false, free_throws: false, team: true)
        when :ball_in_play
          query = query.where(technical_free_throws: false, free_throws: false, team: false, ball_in_play: true)
        when :no_seconds_remaining
          query = query.where(technical_free_throws: false, free_throws: false, team: false, ball_in_play: false, seconds_remaining: 0)
        else
          query = query.where(technical_free_throws: false, free_throws: false, team: false, ball_in_play: false)
          query = query.where { seconds_remaining > 0 }
        end

        query = query.where(Sequel.lit("possessions.#{team}_id = ?", team_id))
                     .where(source: "sample")

        if location == :home
          query = query.where(Sequel.lit("possessions.home_id = ?", team_id))
        else
          query = query.where(Sequel.lit("possessions.visitor_id = ?", team_id))
        end

        PlayByPlay.logger.debug(repository_plays: :count, sql: query.sql) if PlayByPlay.logger.debug?

        query.count
      end

      def seconds_counts(play, team, team_id)
        raise(ArgumentError, "play cannot be nil") unless play
        raise(ArgumentError, "team cannot be nil") unless team
        raise(ArgumentError, "team_id cannot be nil") unless team_id

        play_attributes = {}
        if play.size > 1
          play_attributes = play.last.dup
        end

        query = db[:possessions]
                .where(
                  and_one:        play_attributes[:and_one] || false,
                  assisted:       play_attributes[:assisted] || false,
                  away_from_play: play_attributes[:away_from_play] || false,
                  clear_path:     play_attributes[:clear_path] || false,
                  flagrant:       play_attributes[:flagrant] || false,
                  intentional:    play_attributes[:intentional] || false,
                  point_value:    play_attributes[:point_value],
                  play_type:      play.first.to_s
                )

        if play_attributes[:point_value]
          query = query.where(point_value: play_attributes[:point_value])
        end

        play_team = play_attributes.delete(:team)
        if play_team
          query = query.where(play_team: play_team.to_s)
        end

        query = query
                .where(Sequel.lit("possessions.#{team}_id = ?", team_id))
                .where(source: "sample")
                .group_and_count(:seconds)

        PlayByPlay.logger.debug(repository_plays: :seconds_counts, sql: query.sql) if PlayByPlay.logger.debug?

        query.all
      end

      def add(attributes)
        play_type = attributes.delete(:play_type)
        play_team = attributes.delete(:play_team)

        if play_type && play_type != ""
          play_type = play_type.to_sym

          opponent = attributes.delete(:opponent)
          opponent_id = attributes.delete(:opponent_id)
          player = attributes.delete(:player)
          player_id = attributes.delete(:player_id)
          teammate = attributes.delete(:teammate)
          teammate_id = attributes.delete(:teammate_id)

          play_attributes = {
            opponent: opponent,
            opponent_id: opponent_id,
            player: player,
            player_id: player_id,
            team: play_team,
            teammate: teammate,
            teammate_id: teammate_id
           }
          PLAY_KEYS.each { |key| play_attributes[key] = attributes.delete(key) }

          attributes[:play] = Persistent::Play.new(play_type, play_attributes)
        else
          PLAY_KEYS.each { |key| attributes.delete(key) }
        end

        attributes
      end
    end
  end
end
