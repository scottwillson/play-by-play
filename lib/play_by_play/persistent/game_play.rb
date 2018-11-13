module PlayByPlay
  module Persistent
    # Apply Model::Play to Persistent::Game
    module GamePlay
      def self.play!(game, model_play)
        # play! and entire game`
        # and play! a possession
        # play all of game in model and then persist?
        # in model, where does play source come from? abstract play generator?
        
      end
    end
  end
end

# def self.play!(game, play_type, play_attributes = {})
#   play = Model::Play.new(play_type, play_attributes)
#   possession = Model::GamePlay.play!(game.possession, play)
#   debug_play possession, play
#
#   play = Persistent::Play.new(play_type, play_attributes.merge(possession: game.possession))
#   game.possession.play = play
#
#   possession = Persistent::Possession.new(possession.attributes)
#   game.possessions << possession
#   play
# end

# def self.play!(
#   game,
#   random_play_generator = RandomPlayGenerator.new(PlayByPlay::Repository.new),
#   random_seconds_generator = RandomSecondsGenerator.new(PlayByPlay::Repository.new)
# )
#   PlayByPlay.logger.debug(
#     simulation_game: :play!,
#     date: game.day&.date,
#     game_id: game.id,
#     home: game.home.abbreviation,
#     visitor: game.visitor.abbreviation,
#     begin: Time.now
#   )
#
#   until game.possession.game_over?
#     play = random_play_generator.new_play(game.possession)
#     play = Persistent::Play.from_array(play)
#     play.possession = game.possession
#     game.possession.play = play
#
#     seconds = random_seconds_generator.seconds(game.possession)
#     play.seconds = seconds
#
#     possession = Model::GamePlay.play!(game.possession, play)
#     game.possessions << possession
#
#     if game.possessions.size > 3_000
#       raise Model::InvalidStateError, "Game not over after #{game.possessions.size} plays"
#     end
#   end
#
#   PlayByPlay.logger.debug(
#     simulation_game: :play!,
#     game_id: game.id,
#     end: Time.now
#   )
#
#   game
# end
