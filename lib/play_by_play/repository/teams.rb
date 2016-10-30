require "play_by_play/repository/base"

module PlayByPlay
  module RepositoryModule
    class Teams < Base
      def find(id)
        return unless id
        Persistent::Team.new @db[:teams].where(id: id).first
      end

      def find_by_abbrevation(abbreviation)
        Persistent::Team.new @db[:teams].where(abbreviation: abbreviation).first
      end

      def create(team)
        raise(ArgumentError, "team cannot be nil") unless team
        raise(ArgumentError, "team must have name or abbreviation") if team.abbreviation.nil? && team.name.nil?
        return team if team.id

        attributes = @db[:teams].where(abbreviation: team.abbreviation, name: team.name).first
        return Persistent::Team.new(attributes) if attributes

        save team
      end

      def save(team)
        id = @db[:teams].insert(
          abbreviation: team.abbreviation,
          name: team.name
        )
        team.id = id
        team
      end
    end
  end
end
