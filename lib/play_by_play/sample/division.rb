module PlayByPlay
  module Sample
    class Division
      attr_accessor :id
      attr_reader :conference_id
      attr_reader :name
      attr_reader :teams

      def initialize(id: nil, name: nil, conference_id: nil)
        @teams = []
        @id = id
        @name = name
        @conference_id = conference_id
      end
    end
  end
end
