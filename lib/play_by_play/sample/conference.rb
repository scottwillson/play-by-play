module PlayByPlay
  module Sample
    class Conference
      attr_accessor :id
      attr_reader :divisions
      attr_reader :league_id
      attr_reader :name

      def initialize(id: nil, name: nil, league_id: nil)
        @divisions = []
        @id = id
        @name = name
        @league_id = league_id
      end
    end
  end
end
