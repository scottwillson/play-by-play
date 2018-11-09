require "play_by_play/model/team"
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

        attributes = @db[:teams].where(id: id).first
        return unless attributes

        Persistent::Team.new attributes
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
        all
          .each { |team| stats_to_zero(team) }
          .each { |team| team(team) }
          .reject { |team| team[:games].zero? }
      end

      private

      def stats_to_zero(team)
        team[:fgs] = 0
        team[:fg_attempts] = 0
        team[:fg_percentage] = 0.0
        team[:fts] = 0
        team[:ft_attempts] = 0
        team[:ft_percentage] = 0.0
        team[:opponent_points] = 0
        team[:points] = 0
        team[:three_point_fgs] = 0
        team[:three_point_fg_attempts] = 0
        team[:three_point_fg_percentage] = 0.0
      end

      def team(team)
        plays = @db[:possessions]
                .where(offense_id: team[:id])
                .exclude(play_type: nil)
                .exclude(play_type: "")
                .all

        games = plays.map { |play| play[:game_id] }.uniq.size.to_f
        team[:games] = games

        if games.positive?
          add_stats(team, plays)
        end

        plays = @db[:possessions]
                .where(defense_id: team[:id])
                .exclude(play_type: nil)
                .exclude(play_type: "")
                .all

        if games.positive?
          add_opposition_stats(team, plays)
        end

        team[:points_differential] = team[:points] - team[:opponent_points]

        team
      end

      # rubocop:disable Metrics/AbcSize
      def add_stats(team, plays)
        team[:fgs] = plays.select { |play| play[:play_type] == "fg" }.size / team[:games]
        team[:fg_attempts] = plays.select { |play| play[:play_type] == "fg" || play[:play_type] == "fg_miss" || play[:play_type] == "block" }.size / team[:games]
        if team[:fg_attempts].positive?
          team[:fg_percentage] = team[:fgs] / team[:fg_attempts].to_f
        end
        team[:fts] = plays.select { |play| play[:play_type] == "ft" }.size / team[:games]
        team[:ft_attempts] = plays.select { |play| play[:play_type] == "ft" || play[:play_type] == "ft_miss" }.size / team[:games]
        if team[:ft_attempts].positive?
          team[:ft_percentage] = team[:fts] / team[:ft_attempts].to_f
        end
        team[:three_point_fgs] = plays.select { |play| play[:play_type] == "fg" && play[:point_value] == 3 } .size / team[:games]
        team[:three_point_fg_attempts] = plays.select { |play| play[:point_value] == 3 && (play[:play_type] == "fg" || play[:play_type] == "fg_miss" || play[:play_type] == "block") }.size / team[:games]
        if team[:three_point_fg_attempts].positive?
          team[:three_point_fg_percentage] = team[:three_point_fgs] / team[:three_point_fg_attempts].to_f
        end
        team[:assists] = plays.select { |play| play[:assisted] }.size / team[:games]
        team[:turnovers] = plays.select { |play| play[:play_type] == "turnover" || play[:play_type] == "steal" }.size / team[:games]

        team[:points] = total_points(plays) / team[:games]
      end
      # rubocop:enable Metrics/AbcSize

      def add_opposition_stats(team, plays)
        team[:opponent_fgs] = plays.select { |play| play[:play_type] == "fg" }.size / team[:games]
        team[:opponent_fg_attempts] = plays.select { |play| play[:play_type] == "fg" || play[:play_type] == "fg_miss" || play[:play_type] == "block" }.size / team[:games]
        if team[:opponent_fg_attempts].positive?
          team[:opponent_fg_percentage] = team[:opponent_fgs] / team[:opponent_fg_attempts].to_f
        end
        team[:opponent_three_point_fgs] = plays.select { |play| play[:play_type] == "fg" && play[:point_value] == 3 } .size / team[:games]
        team[:opponent_three_point_fg_attempts] = plays.select { |play| play[:point_value] == 3 && (play[:play_type] == "fg" || play[:play_type] == "fg_miss" || play[:play_type] == "block") }.size / team[:games]
        if team[:opponent_three_point_fg_attempts].positive?
          team[:opponent_three_point_fg_percentage] = team[:opponent_three_point_fgs] / team[:opponent_three_point_fg_attempts].to_f
        end
        team[:steals] = plays.select { |play| play[:play_type] == "steal" }.size / team[:games]
        team[:blocks] = plays.select { |play| play[:play_type] == "block" }.size / team[:games]
        team[:opponent_points] = total_points(plays) / team[:games]
      end

      def total_points(plays)
        plays.inject(0) do |total, play|
          case play[:play_type]
          when "fg"
            total + (play[:point_value] || 2)
          when "ft"
            total + 1
          else
            total
          end
        end
      end
    end
  end
end
