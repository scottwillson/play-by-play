require "spec_helper"
require "play_by_play/persistent/game"
require "play_by_play/repository"

module PlayByPlay
  module Persistent
    RSpec.describe Game do
      describe "#home=" do
        it "sets @home and @home_id" do
          repository = Repository.new
          repository.reset!

          home = Persistent::Team.new(abbreviation: "SEA")
          visitor = Persistent::Team.new(abbreviation: "POR")
          repository.teams.save home
          repository.teams.save visitor
          home_id = home.id
          visitor_id = visitor.id

          game = Persistent::Game.new(home: home, visitor: visitor)
          expect(game.home).to eq(home)
          expect(game.home_id).to eq(home_id)
          expect(game.visitor).to eq(visitor)
          expect(game.visitor_id).to eq(visitor_id)
          expect(game.home).to_not eq(visitor)

          game.home = home

          expect(game.home).to eq(home)
          expect(game.home_id).to eq(home_id)
          expect(game.visitor).to eq(visitor)
          expect(game.visitor_id).to eq(visitor_id)
          expect(game.home).to_not eq(visitor)

          game.visitor = visitor

          expect(game.home).to eq(home)
          expect(game.home_id).to eq(home_id)
          expect(game.visitor).to eq(visitor)
          expect(game.visitor_id).to eq(visitor_id)
          expect(game.home).to_not eq(visitor)
        end
      end
    end
  end
end
