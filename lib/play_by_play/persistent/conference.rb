module PlayByPlay
  module Persistent
    class Conference
      attr_accessor :id
      attr_reader :divisions
      attr_reader :league_id
      attr_reader :name

      def initialize(league_id: nil, divisions: nil, id: nil, name: nil)
        @divisions = divisions
        @id = id
        @league_id = league_id
        @name = name
      end
    end
  end
end
