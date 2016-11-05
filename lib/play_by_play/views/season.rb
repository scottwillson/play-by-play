module PlayByPlay
  module Views
    class Season
      def initialize(season)
        @season = season
      end

      def to_s
        strings = []
        @season.league.conferences.each do |conference|
          strings << ""
          strings << conference.name
          strings << "=" * conference.name.size

          conference.divisions.each do |division|
            strings << ""
            strings << division.name
            strings << "-" * division.name.size

            division.teams.sort_by { |t| @season.losses(t) } .each do |team|
              strings << "#{team.name} #{@season.wins(team)} #{@season.losses(team)}"
            end
          end
        end

        strings.join("\n")
      end
    end
  end
end
