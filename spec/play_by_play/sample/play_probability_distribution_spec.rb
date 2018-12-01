require "spec_helper"
require "play_by_play/model/play"
require "play_by_play/model/possession"
require "play_by_play/sample/game"
require "play_by_play/sample/season"
require "play_by_play/sample/play_probability_distribution"
require "play_by_play/repository"

module PlayByPlay
  module Sample
    RSpec.describe PlayProbabilityDistribution do
      describe ".for" do
        it "returns instances of PlayProbability", database: true do
          sample_game = Game.new_game("001", "GSW", "POR")

          Persistent::GamePlay.add_play sample_game, Model::Play.new(:jump_ball, team: :visitor)
          Persistent::GamePlay.add_play sample_game, Model::Play.new(:personal_foul, team: :defense) # home (visitor on offense)
          Persistent::GamePlay.add_play sample_game, Model::Play.new(:personal_foul, team: :defense ) # home (visitor on offense)
          Persistent::GamePlay.add_play sample_game, Model::Play.new(:fg, point_value: 3, assisted: true) # visitor
          Persistent::GamePlay.add_play sample_game, Model::Play.new(:fg, point_value: 3, assisted: true) # home
          Persistent::GamePlay.add_play sample_game, Model::Play.new(:fg, point_value: 3, assisted: true) # visitor
          Persistent::GamePlay.add_play sample_game, Model::Play.new(:fg_miss) # home
          Persistent::GamePlay.add_play sample_game, Model::Play.new(:rebound, team: :defense) # visitor
          Persistent::GamePlay.add_play sample_game, Model::Play.new(:fg, point_value: 3) # visitor

          repository = Repository.new
          repository.reset!

          season = Sample::Season.new_persistent
          day = Persistent::Day.new(season: season)
          sample_game.day = day
          repository.seasons.save season

          game = Persistent::Game.new(visitor: repository.teams.find_by_abbrevation("GSW"), home: repository.teams.find_by_abbrevation("POR"))
          play_probability_distribution = Sample::PlayProbabilityDistribution.new(repository)

          possession = Persistent::Possession.new(game: game)
          expect(possession.key).to be_nil
          possession_play_probability_distribution = play_probability_distribution.for(game.possession)
          expect(possession_play_probability_distribution.size).to eq(24)
          expect(possession_play_probability_distribution.map(&:probability)).to match_array([ 1, 1 ] + [ 0 ] * 22)

          possession = Persistent::Possession.new(game: game, ball_in_play: true)
          possession_play_probability_distribution = play_probability_distribution.for(possession)
          expect(possession_play_probability_distribution.size).to eq(26)
          expect(possession_play_probability_distribution.map(&:probability)).to match_array([ 1, 1 ] + [ 0 ] * 24)

          possession = Persistent::Possession.new(game: game, ball_in_play: true, offense: :visitor, team: :visitor)
          possession_play_probability_distribution = play_probability_distribution.for(possession)
          expect(possession_play_probability_distribution.size).to eq(54)
          expect(possession_play_probability_distribution.map(&:probability)).to match_array([ 2, 2, 2, 2, 1, 1 ] + [ 0 ] * 48)

          possession = Persistent::Possession.new(game: game, ball_in_play: true, offense: :home, team: :home)
          possession_play_probability_distribution = play_probability_distribution.for(possession)
          expect(possession_play_probability_distribution.size).to eq(54)
          expect(possession_play_probability_distribution.map(&:probability)).to match_array([ 1, 1, 1, 1 ] + [ 0 ] * 50)
        end
      end
    end
  end
end
