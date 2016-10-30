require "spec_helper"
require "play_by_play/repository"
require "play_by_play/sample/league"

module PlayByPlay
  module Sample
    RSpec.describe League do
      describe ".import", database: true do
        it "creates League from HTML" do
          repository = Repository.new
          repository.reset!

          league = League.import("spec/data", 2014, repository: repository)
          expect(repository.league.exists?).to be_truthy
          expect(league.conferences.size).to eq(2)
          expect(league.conferences[0].divisions.size).to eq(3)
          expect(league.conferences[1].divisions.size).to eq(3)
          expect(league.conferences[0].divisions[0].teams.size).to eq(5)
          expect(league.conferences[1].divisions[2].teams.size).to eq(5)

          portland = league.conferences
                           .detect { |conference| conference.name == "Western Conference" }
                           .divisions
                           .detect { |division| division.name == "Northwest" }
                           .teams
                           .detect { |team| team.name == "Portland Trail Blazers" }

          expect(portland).to_not eq(nil)
          expect(league.teams.size).to eq(30)

          league = repository.league.find

          portland = league.conferences
                           .detect { |conference| conference.name == "Western Conference" }
                           .divisions
                           .detect { |division| division.name == "Northwest" }
                           .teams
                           .detect { |team| team.name == "Portland Trail Blazers" }

          expect(portland).to_not eq(nil)

          expect(league.teams.size).to eq(30)
        end
      end
    end
  end
end
