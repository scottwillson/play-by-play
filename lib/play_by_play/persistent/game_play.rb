module PlayByPlay
  module Persistent
    # Apply Model::Play to Persistent::Game
    module GamePlay
      # play! and entire game`
      # and play! a possession
      # play all of game in model and then persist?
      # in model, where does play source come from? abstract play generator?

      # Play a game until it is finished.
      def self.play!(game, play_generator, seconds_generator)
        unless game.is_a?(Persistent::Game)
          raise ArgumentError, "game must be a Persistent::Game, but is a #{game.class}"
        end

        until game.over?
          play = play_generator.new_play(game)
          seconds = seconds_generator.seconds(game)
          play.seconds = seconds

          possession = game.possession.to_model
          possession = Model::GamePlay.play!(possession, play)
          game.add_play play, play_generator.row
          game.add_possession possession
        end
      end
    end
  end
end
