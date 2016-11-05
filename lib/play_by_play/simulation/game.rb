require "play_by_play/model/game_play"
require "play_by_play/model/invalid_state_error"
require "play_by_play/model/possession"
require "play_by_play/persistent/game"
require "play_by_play/persistent/team"
require "play_by_play/repository"
require "play_by_play/simulation/random_play_generator"

module PlayByPlay
  module Simulation
    module Game
      def self.play!(game, random_play_generator = RandomPlayGenerator.new(PlayByPlay::Repository.new))
        until game.possession.game_over?
          # print "#{game.possession.period} #{game.possession.seconds_remaining} #{game.visitor.name} #{game.possession.visitor.points} #{game.home.name} #{game.possession.home.points} #{game.possession.team} (#{game.possession.offense})"
          play = random_play_generator.new_play(game.possession)
          # p play
          game.possessions << Model::GamePlay.play!(game.possession, play)

          if game.possessions.size > 3_000
            raise Model::InvalidStateError, "Game not over after #{game.possessions.size} plays"
          end
        end

        game
      end
    end
  end
end
