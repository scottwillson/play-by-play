require "play_by_play/model/game_play"
require "play_by_play/model/invalid_state_error"
require "play_by_play/model/possession"
require "play_by_play/persistent/game"
require "play_by_play/persistent/play"
require "play_by_play/persistent/team"
require "play_by_play/repository"
require "play_by_play/simulation/random_play_generator"
require "play_by_play/simulation/random_seconds_generator"

module PlayByPlay
  module Simulation
    module Game
      def self.play!(
        game,
        random_play_generator = RandomPlayGenerator.new(PlayByPlay::Repository.new),
        random_seconds_generator = RandomSecondsGenerator.new(PlayByPlay::Repository.new)
      )
        PlayByPlay.logger.debug(
          simulation_game: :play!,
          date: game.day&.date,
          game_id: game.id,
          home: game.home.abbreviation,
          visitor: game.visitor.abbreviation,
          begin: Time.now
        )

        model_possession = Model::Possession.new
        until game.possession.game_over?
          model_play = random_play_generator.new_play(game.possession)
          play = Persistent::Play.from_array(model_play)
          play.possession = game.possession
          game.possession.play = play

          seconds = random_seconds_generator.seconds(game.possession)
          play.seconds = seconds

          model_possession = Model::GamePlay.play!(model_possession, model_play)

          possession = Persistent::Possession.new(model_possession.attributes)
          possession.game = game
          game.possessions << possession

          if game.possessions.size > 3_000
            raise Model::InvalidStateError, "Game not over after #{game.possessions.size} plays"
          end
        end

        PlayByPlay.logger.debug(
          simulation_game: :play!,
          game_id: game.id,
          end: Time.now
        )

        game
      end
    end
  end
end
