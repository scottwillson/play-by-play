module PlayByPlay
  module Persistent
    class Division
      attr_accessor :id
      attr_reader :conference_id
      attr_reader :name
      attr_reader :teams

      def initialize(conference_id: nil, id: nil, name: nil, teams: [])
        @conference_id = conference_id
        @id = id
        @name = name
        @teams = teams
      end
    end
  end
end
