module PlayByPlay
  module Views
    class Season
      def initialize(season)
        @season = season
      end

      def to_s
        @season.teams.map { |team| "#{team.name} #{team.wins} #{team.losses}" }.join("\n")
      end
    end
  end
end
