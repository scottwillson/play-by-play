module PlayByPlay
  module Sample
    class Team
      attr_accessor :id
      attr_reader :division_id
      attr_reader :name

      def initialize(division_id: nil, id: nil, name: nil)
        @division_id = division_id
        @id = id
        @name = name
      end
    end
  end
end
