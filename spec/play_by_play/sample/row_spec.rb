require "spec_helper"
require "play_by_play/sample/game"
require "play_by_play/sample/row"
require "play_by_play/model/possession"

module PlayByPlay
  module Sample
    RSpec.describe Row do
      let(:row) { Row.new(Game.new("0021400001", "ORL", "NOP"), []) }

      describe ".description" do
        it "concatenates description fields" do
          expect(row.description).to eq("")

          row.homedescription = "Jump ball"
          row.visitordescription = nil
          expect(row.description).to eq("Jump ball")

          row.homedescription = nil
          row.visitordescription = "Turnover"
          expect(row.description).to eq("Turnover")

          row.homedescription = "Shot"
          row.visitordescription = "PF"
          expect(row.description).to eq("Shot PF")
        end
      end

      describe ".play_type" do
        it "maps number to symbol" do
          row.eventmsgtype = 5
          expect(row.play_type).to eq(:turnover)
        end

        it "is :personal_foul for defense away from ball foul" do
          row.possession = Model::Possession.new(team: :visitor, offense: :visitor)
          row.eventmsgtype = 6
          row.eventmsgactiontype = 6
          row.person1type = 4
          row.person2type = 5
          row.person3type = 0
          expect(row.play_type).to eq(:personal_foul)
          expect(row.away_from_play?).to eq(true)
          expect(row.play_team).to eq(:defense)
          expect(row.team).to eq(:home)
        end

        it "is :personal_foul for offense away from ball foul" do
          row.possession = Model::Possession.new(team: :visitor, offense: :visitor)
          row.eventmsgtype = 6
          row.eventmsgactiontype = 6
          row.person1type = 5
          row.person2type = 4
          row.person3type = 1
          expect(row.play_type).to eq(:personal_foul)
          expect(row.play_team).to eq(:offense)
          expect(row.team).to eq(:visitor)
        end
      end

      describe ".team" do
        it "finds team for technical foul" do
          row.eventmsgtype = 6
          row.eventmsgactiontype = 11
          row.person1type = 5
          row.person2type = 0
          row.person3type = 1

          expect(row.team).to eq(:visitor)
        end

        it "finds team for rebound" do
          row.eventmsgtype = 4
          row.eventmsgactiontype = 0
          row.person1type = 5
          row.person2type = 0
          row.person3type = 0

          expect(row.team).to eq(:visitor)
        end
      end

      describe ".seconds_remaining" do
        it "parses time string" do
          file = Game.new("0021400001", "ORL", "NOP")
          file.headers = %w( pctimestring )
          row = Row.new(file, [ "5:12" ])
          expect(row.seconds_remaining).to eq(312)
        end
      end

      describe ".play_team" do
        context "defense technical foul" do
          it "is :defense" do
            file = Game.new("0021400001", "ORL", "NOP")
            file.headers = %w( eventmsgtype eventmsgactiontype person1type )
            row = Row.new(file, [ 6, 267, 5 ])
            row.possession = Model::Possession.new(team: :home)
            expect(row.play_team).to eq(:defense)
          end
        end
      end

      describe "jump_ball" do
        it "assigns team for possession 0021400017" do
          # Jump Ball Pekovic vs. Drummond: Tip to
          row.eventmsgtype = 10
          row.eventmsgactiontype = 0
          row.person1type = 4
          row.person2type = 5
          row.person3type = 3
          row.player1_team_id = 1610612750
          row.player2_team_id = 1610612765
          row.player3_team_id = 1610612765
          row.player1_id = 201593
          row.player2_id = 203083
          row.player3_id = 2746

          expect(row.play_team).to eq(:home)
        end

        it "assigns team for possession 0021400040" do
          row.eventmsgtype = 10
          row.eventmsgactiontype = 0
          row.person1type = 4
          row.person2type = 5
          row.person3type = 3
          row.player1_team_id = 1610612748
          row.player2_team_id = 1610612761
          row.player3_team_id = 1610612761
          row.player1_id = 203120
          row.player2_id = 202335
          row.player3_id = 203082

          expect(row.play_team).to eq(:home)
        end
      end
    end
  end
end
