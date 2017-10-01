require "play_by_play/model/game_play"
require "play_by_play/model/invalid_state_error"
require "play_by_play/model/possession"
require "play_by_play/persistent/game"
require "play_by_play/persistent/play"
require "play_by_play/persistent/team"
require "play_by_play/repository"
require "play_by_play/simulation/random_play_generator"

module PlayByPlay
  module Simulation
    module Game
      def self.play!(game, random_play_generator = RandomPlayGenerator.new(PlayByPlay::Repository.new))
        until game.possession.game_over?
          play = random_play_generator.new_play(game.possession)
          possession = Model::GamePlay.play!(game.possession, play)

          play = Persistent::Play.from_array(play)
          play.possession = game.possession
          game.possession.play = play
          game.possessions << possession

          if game.possessions.size > 3_000
            raise Model::InvalidStateError, "Game not over after #{game.possessions.size} plays"
          end
        end

        game
      end
    end
  end
end
