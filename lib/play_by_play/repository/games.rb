require "play_by_play/repository/base"

module PlayByPlay
  module RepositoryModule
    class Games < Base
      def exists?(nba_id)
        return false if nba_id.nil?

        !@db[:games].where(nba_id: nba_id).empty?
      end

      def save_possessions(game)
        game.possessions.each do |possession|
          possession.game = game
          repository.possessions.save possession
        end
      end

      def save(game)
        return false if exists?(game.nba_id)

        game.home = repository.teams.find_or_create(game.home)
        game.visitor = repository.teams.find_or_create(game.visitor)

        game.id = @db[:games].insert(
          errors: game.errors,
          error_eventnum: game.error_eventnum,
          home_id: game.home.id,
          nba_id: game.nba_id,
          visitor_id: game.visitor.id
        )

        save_possessions game
        repository.plays.save_all game.plays

        true
      end

      def find(id)
        attributes = @db[:games].where(id: id).first

        attributes[:home] = team(attributes[:home_id])
        attributes[:visitor] = team(attributes[:visitor_id])

        Persistent::Game.new attributes
      end

      def all(page = 1)
        @db[:games].exclude(error_eventnum: nil).paginate(page, 20).all
      end

      def plays(game_id)
        @db[:plays]
          .select(:plays__id, :and_one, :assisted, :away_from_play, :clear_path, :flagrant, :intentional, :point_value, :possession_id, :plays__team, :type)
          .join(:possessions, id: :possession_id)
          .where(possessions__game_id: game_id)
          .map do |attributes|
            type = attributes.delete(:type)
            if type && type != ""
              type = type.to_sym
            else
              type = nil
            end
            Persistent::Play.new(type, attributes)
          end
      end

      def possessions(game_id)
        @db[:possessions].where(game_id: game_id).map do |attributes|
          attributes.delete(:defense_id)
          attributes.delete(:home_id)
          attributes.delete(:offense_id)
          attributes.delete(:visitor_id)

          [ :next_team, :offense, :opening_tip ].each do |key|
            if attributes[key] && attributes[key] != ""
              attributes[key] = attributes[key].to_sym
            else
              attributes[key] = nil
            end
          end

          if attributes[:team]
            attributes[:team] = attributes[:offense]
          else
            attributes[:team] = nil
          end

          if attributes[:free_throws]
            attributes[:free_throws] = [ attributes[:offense] ]
          else
            attributes[:free_throws] = []
          end

          if attributes[:technical_free_throws]
            attributes[:technical_free_throws] = [ attributes[:offense] ]
          else
            attributes[:technical_free_throws] = []
          end

          Persistent::Possession.new(attributes)
        end
      end

      def rows(nba_id)
        game_id = db[:games].where(nba_id: nba_id).first[:id]
        db[:rows].where(game_id: game_id).all
      end
    end
  end
end
