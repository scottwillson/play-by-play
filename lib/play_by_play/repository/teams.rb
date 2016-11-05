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

      def find_or_create(team)
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
                  .where("play_type is not null and play_type != ''")
                  .all

          games = plays.map { |play| play[:game_id] }.uniq.size

          team[:fgs] = 0
          team[:fg_attempts] = 0
          team[:fg_percentage] = 0.0
          team[:points] = 0

          if games.positive?
            team[:fgs] = plays.select { |play| play[:play_type] == "fg" }.size / games.to_f
            team[:fg_attempts] = plays.select { |play| play[:play_type] == "fg" || play[:play_type] == "fg_miss" || play[:play_type] == "block" }.size / games.to_f
            if team[:fg_attempts].positive?
              team[:fg_percentage] = team[:fgs] / team[:fg_attempts].to_f
            end
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

          team
        end
      end
    end
  end
end
