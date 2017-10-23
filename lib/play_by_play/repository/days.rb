require "play_by_play/persistent/day"
require "play_by_play/repository/base"

module PlayByPlay
  module RepositoryModule
    class Days < Base
      def first_by_date(date)
        attributes = @db[:days].where(date: date).first
        if attributes
          Persistent::Day.new attributes
        end
      end

      def save(season_id, day)
        day_id = first_by_date(day.date)&.id || @db[:days].insert(date: day.date, season_id: season_id)
        day.id = day_id

        day.games.each do |game|
          repository.games.save game
        end

        day_id
      end

      def year(year)
        @db[:days]
          .select(:date, Sequel[:days][:id])
          .join(:seasons, id: :season_id)
          .where(Sequel.lit("date_part('year', seasons.start_at) = ?", year))
          .order(:date)
          .map do |attributes|
            attributes.delete(:start_at)
            Persistent::Day.new attributes
          end
      end
    end
  end
end
