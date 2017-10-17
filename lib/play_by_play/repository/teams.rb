require "play_by_play/repository/base"

module PlayByPlay
  module RepositoryModule
    class Teams < Base
      def all
        @db[:teams].all
      end

      def create(team)
        raise(ArgumentError, "team cannot be nil") unless team
        raise(ArgumentError, "team must have name or abbreviation") if team.abbreviation.nil? && team.name.nil?
        return team if team.id

        attributes = @db[:teams].where(abbreviation: team.abbreviation, name: team.name).first
        return Persistent::Team.new(attributes) if attributes

        save team
      end

      def find(id)
        return unless id
        Persistent::Team.new @db[:teams].where(id: id).first
      end

      def find_by_abbrevation(abbreviation)
        attributes = @db[:teams].where(abbreviation: abbreviation).first

        if attributes
          Persistent::Team.new attributes
        end
      end

      def first_or_create(team)
        find_by_abbrevation(team.abbreviation) || create(team)
      end

      def save(team)
        id = @db[:teams].insert(
          abbreviation: team.abbreviation,
          name: team.name
        )
        team.id = id
        team
      end

      def years
        all.map do |team|
          plays = @db[:possessions]
                  .where(offense_id: team[:id])
                  .exclude(play_type: nil)
                  .exclude(play_type: "")
                  .all

          games = plays.map { |play| play[:game_id] }.uniq.size
          team[:games] = games

          team[:fgs] = 0
          team[:fg_attempts] = 0
          team[:fg_percentage] = 0.0
          team[:fts] = 0
          team[:ft_attempts] = 0
          team[:ft_percentage] = 0.0
          team[:three_point_fgs] = 0
          team[:three_point_fg_attempts] = 0
          team[:three_point_fg_percentage] = 0.0
          team[:points] = 0

          if games.positive?
            team[:fgs] = plays.select { |play| play[:play_type] == "fg" }.size / games.to_f
            team[:fg_attempts] = plays.select { |play| play[:play_type] == "fg" || play[:play_type] == "fg_miss" || play[:play_type] == "block" }.size / games.to_f
            if team[:fg_attempts].positive?
              team[:fg_percentage] = team[:fgs] / team[:fg_attempts].to_f
            end
            team[:fts] = plays.select { |play| play[:play_type] == "ft" }.size / games.to_f
            team[:ft_attempts] = plays.select { |play| play[:play_type] == "ft" || play[:play_type] == "ft_miss" }.size / games.to_f
            if team[:ft_attempts].positive?
              team[:ft_percentage] = team[:fts] / team[:ft_attempts].to_f
            end
            team[:three_point_fgs] = plays.select { |play| play[:play_type] == "fg" && play[:point_value] == 3 } .size / games.to_f
            team[:three_point_fg_attempts] = plays.select { |play| play[:point_value] == 3 && (play[:play_type] == "fg" || play[:play_type] == "fg_miss" || play[:play_type] == "block") }.size / games.to_f
            if team[:three_point_fg_attempts].positive?
              team[:three_point_fg_percentage] = team[:three_point_fgs] / team[:three_point_fg_attempts].to_f
            end
            team[:assists] = plays.select { |play| play[:assisted] }.size / games.to_f
            team[:turnovers] = plays.select { |play| play[:play_type] == "turnover" || play[:play_type] == "steal" }.size / games.to_f

            team[:points] = plays.inject(0) do |total, play|
              case play[:play_type]
              when "fg"
                total + (play[:point_value] || 2)
              when "ft"
                total + 1
              else
                total
              end
            end / games.to_f
          end

          plays = @db[:possessions]
                  .where(defense_id: team[:id])
                  .exclude(play_type: nil)
                  .exclude(play_type: "")
                  .all

          games = plays.map { |play| play[:game_id] }.uniq.size

          if games.positive?
            team[:opponent_fgs] = plays.select { |play| play[:play_type] == "fg" }.size / games.to_f
            team[:opponent_fg_attempts] = plays.select { |play| play[:play_type] == "fg" || play[:play_type] == "fg_miss" || play[:play_type] == "block" }.size / games.to_f
            if team[:opponent_fg_attempts].positive?
              team[:opponent_fg_percentage] = team[:opponent_fgs] / team[:opponent_fg_attempts].to_f
            end
            team[:opponent_three_point_fgs] = plays.select { |play| play[:play_type] == "fg" && play[:point_value] == 3 } .size / games.to_f
            team[:opponent_three_point_fg_attempts] = plays.select { |play| play[:point_value] == 3 && (play[:play_type] == "fg" || play[:play_type] == "fg_miss" || play[:play_type] == "block") }.size / games.to_f
            if team[:opponent_three_point_fg_attempts].positive?
              team[:opponent_three_point_fg_percentage] = team[:opponent_three_point_fgs] / team[:opponent_three_point_fg_attempts].to_f
            end
            team[:steals] = plays.select { |play| play[:play_type] == "steal" }.size / games.to_f
            team[:blocks] = plays.select { |play| play[:play_type] == "block" }.size / games.to_f
            team[:opponent_points] = plays.inject(0) do |total, play|
              case play[:play_type]
              when "fg"
                total + (play[:point_value] || 2)
              when "ft"
                total + 1
              else
                total
              end
            end / games.to_f

            team[:points_differential] = team[:points] - team[:opponent_points]
          end

          team
        end.reject { |team| team[:games].zero? }
      end
    end
  end
end
