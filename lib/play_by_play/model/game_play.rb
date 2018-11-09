Dir["#{__dir__}/game_play/*.rb"].each do |file|
  require "play_by_play/model/game_play/#{File.basename(file)}"
end

module PlayByPlay
  module Model
    # Apply Plays to Possession to produce a new Possession. Or: reduces current state + action to a new state.
    # Require and include every Play module in game_play.
    # GamePlay and its play modules are all pure methods: given a state and and action, they always return the same state, and
    # they never change external state.
    module GamePlay
      def self.play!(possession, play)
        unless play.is_a?(Model::Play)
          raise ArgumentError, "play must be a Play, but is #{play.class} #{play}"
          # play = Model::Play.new(play.first, *play[1..-1])
        end

        possession
          .merge(play_updates(possession, play))
          .merge(seconds_remaining(possession, play))
          .merge(opening_tip(possession, play))
          .merge(errors!(possession, play))
      end

      def self.play_updates(possession, play)
        send play.type, possession, play
      end

      def self.errors!(possession, play)
        errors = []

        unless PlayMatrix.accessible?(possession, play)
          errors << "#{play.key} not accessible for #{possession.key}. Accessible plays: #{PlayMatrix.accessible_plays(possession.key)}"
        end

        if possession.seconds_remaining > 24 && play.key == [ :period_end ]
          errors << ":period_end invalid with #{possession.seconds_remaining} seconds remaining"
        end

        raise(InvalidStateError, errors) unless errors.empty?

        { errors: errors }
      end

      def self.add_points(possession, points)
        team = possession.team
        { team.key => { points: team.points + points } }
      end

      def self.increment_period_personal_fouls(possession, team)
        possession_team = possession.team(team)
        attributes = { period_personal_fouls: possession_team.period_personal_fouls + 1 }

        if possession.seconds_remaining <= 120
          attributes = attributes.merge(personal_foul_in_last_two_minutes: true)
        end

        { instance.key => instance.merge(attributes) }
      end

      def self.add_technical_free_throws(possession, play)
        new_fts = possession.technical_free_throws.dup
        new_fts << possession.other_team(play.team)

        if play.flagrant?
          new_fts << possession.other_team(play.team)
        end

        new_fts
      end

      def self.decrement_free_throws(possession)
        if possession.technical_free_throws?
          new_fts = possession.technical_free_throws.dup
          new_fts.pop
          { technical_free_throws: new_fts }
        else
          new_fts = possession.free_throws.dup
          new_fts.pop
          { free_throws: new_fts }
        end
      end

      def self.opening_tip(possession, play)
        unless possession.opening_tip
          { opening_tip: play.team }
        end
      end

      def self.seconds_remaining(possession, play)
        return if play.type == :period_end

        next_seconds_remaining = possession.seconds_remaining - play.seconds
        next_seconds_remaining = 0 if next_seconds_remaining < 0
        { seconds_remaining: next_seconds_remaining }
      end
    end
  end
end
