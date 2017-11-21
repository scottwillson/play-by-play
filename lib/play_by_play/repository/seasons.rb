require "play_by_play/persistent/season"
require "play_by_play/repository/base"

module PlayByPlay
  module RepositoryModule
    class Seasons < Base
      def save(season)
        season_id = year(season.start_at.year)&.id ||
                    @db[:seasons].insert(source: season.source, start_at: season.start_at)

        season.days.each do |day|
          repository.days.save season_id, day
        end

        season_id
      end

      def create(season)
        season_id = @db[:seasons].insert(source: season.source, start_at: season.start_at)

        season.days.each do |day|
          repository.days.save season_id, day
        end

        season_id
      end

      def days(season)
        @db[:days].where(season_id: season.id).all
                  .map do |attributes|
                    attributes.delete(:start_at)
                    Persistent::Day.new attributes
                  end
      end

      def simulations
        @db[:seasons].where(source: "simulation").all.map do |attributes|
          season = Persistent::Season.new(attributes)
          season.league = repository.league.find
          season.days = days(season)
          repository.games.add_to(season)
          season.games.each do |game|
            repository.games.plays(game.id).each do |play|
              possession = Model::GamePlay.play!(game.possession, play)

              play.possession = game.possession
              game.possession.play = play
              game.possessions << possession
            end
          end

          season
        end
      end

      def year(year)
        attributes = @db[:seasons].where(Sequel.lit("date_part('year', start_at) = ?", year)).first
        Persistent::Season.new(attributes) if attributes
      end
    end
  end
end
