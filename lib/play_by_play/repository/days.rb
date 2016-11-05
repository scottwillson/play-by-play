require "play_by_play/persistent/day"
require "play_by_play/repository/base"

module PlayByPlay
  module RepositoryModule
    class Days < Base
      def year(year)
        @db[:days]
          .select(:days__id, :date)
          .join(:seasons, id: :season_id)
          .where("date_part('year', seasons.start_at) = ?", year)
          .map do |attributes|
            attributes.delete(:start_at)
            Persistent::Day.new attributes
          end
      end

      def save(season_id, day)
        day_id = @db[:days].insert(date: day.date, season_id: season_id)
        day.games.each do |game|
          repository.games.save day_id, game
        end

        day_id
      end
    end
  end
end
