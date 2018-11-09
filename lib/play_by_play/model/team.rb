module PlayByPlay
  module Model
    class Team
      include Duplication

      attr_accessor :id

      attr_reader :abbreviation
      attr_reader :division_id
      attr_reader :games
      attr_reader :name

      def initialize(attributes)
        @games = []

        attributes = attributes.dup
        @abbreviation = attributes.delete(:abbreviation)
        @division_id = attributes.delete(:division_id)
        @id = attributes.delete(:id)
        @name = attributes.delete(:name)
      end

      def attributes
        @attributes ||= {
          abbreviation: abbreviation,
          division_id: division_id,
          id: id,
          key: key,
          name: name,
          period_personal_fouls: period_personal_fouls,
          personal_foul_in_last_two_minutes: personal_foul_in_last_two_minutes,
          points: points
        }
      end

      def wins
        games.select { |game| game.winner == self }.size
      end

      def losses
        games.select { |game| game.loser == self }.size
      end

      def inspect
        "#<PlayByPlay::Persistent::Team #{id} #{name} #{abbreviation} #{key}>"
      end

      def ==(other)
        return false unless self.class == other.class

        if id
          id == other.id
        else
          super
        end
      end

      def to_s
        name.to_s
      end
    end
  end
end
