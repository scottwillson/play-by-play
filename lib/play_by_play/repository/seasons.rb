require "play_by_play/persistent/season"
require "play_by_play/repository/base"

module PlayByPlay
  module RepositoryModule
    class Seasons < Base
      def year(year)
        Persistent::Season.new(@db[:seasons].where("date_part('year', start_at) = ?", year).first)
      end

      def first_or_create(season)
        if @db[:seasons].where("date_part('year', start_at) = ?", season.start_at.year).first
          year season.start_at.year
        else
          save season
        end
      end

      def save(season)
        season_id = @db[:seasons].insert(start_at: season.start_at)

        season.days.each do |day|
          repository.days.save season_id, day
        end

        season_id
      end
    end
  end
end
