module PlayByPlay
  module Persistent
    class Player
      attr_accessor :id
      attr_accessor :team_id
      attr_reader :name
      attr_reader :nba_id

      def initialize(id: nil, name: nil, nba_id: nil, team_id: nil)
        @id = id
        @name = name
        @nba_id = nba_id
        @team_id = team_id
      end

      def to_s
        "#<PlayByPlay::Persistent::Player #{id} #{name} #{nba_id} #{team_id}>"
      end
    end
  end
end
