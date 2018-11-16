module PlayByPlay
  module Sample
    class PlayGenerator
      def initialize(rows)
        @row_index = 0
        @rows = rows
      end

      def new_play(possession)
        row = next_row(possession)
        row.possession = possession
        Game.debug possession, row
        Model::Play.new row.play_type, row.play_attributes
      end

      def next_row(possession)
        @rows[(@row_index + 1)..-1].each do |row|
          @row_index += 1
          next if Game.ignore?(possession, row)
          return row
        end
      end

      def row
        @rows[@row_index]
      end

      def seconds(_possession)
        row.seconds
      end
    end
  end
end
