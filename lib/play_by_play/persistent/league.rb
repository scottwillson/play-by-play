module PlayByPlay
  module Persistent
    class League
      attr_accessor :id
      attr_reader :conferences

      def initialize(id: nil)
        @conferences = []
        @id = id
      end

      def teams
        conferences.map(&:divisions).flatten.map(&:teams).flatten
      end
    end
  end
end
