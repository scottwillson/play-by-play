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

      def year(year)
        attributes = @db[:seasons].where(Sequel.lit("date_part('year', start_at) = ?", year)).first
        if attributes
          Persistent::Season.new attributes
        end
      end
    end
  end
end
