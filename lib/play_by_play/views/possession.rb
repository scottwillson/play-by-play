module PlayByPlay
  module Views
    class Possession
      def initialize(possession)
        @possession = possession
      end

      def to_s
        "visitor #{@possession.visitor.points}\nhome #{@possession.home.points}\n"
      end
    end
  end
end
