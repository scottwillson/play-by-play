require "play_by_play/model/game_play"

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
          possession = game.possession
          play = play_generator.new_play(possession)
          row = play_generator.row
          seconds = seconds_generator.seconds(possession, play.key)

          begin
            add_play game, play, seconds, row
          rescue Model::InvalidStateError, ArgumentError => e
            raise e if ENV["DBEUG"]
            game.error_eventnum = row.eventnum
            game.errors << e.message
            break
          end
        end
      end

      def self.add_play(game, play, seconds = 1, row = nil)
        play.seconds = seconds
        possession = game.possession.to_model
        possession = Model::GamePlay.play!(possession, play)
        game.add_play play, row
        game.add_possession possession
      end
    end
  end
end
