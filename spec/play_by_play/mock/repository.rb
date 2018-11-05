require "play_by_play/mock/game"
require "play_by_play/persistent/play"

module PlayByPlay
  module Mock
    class Repository
      def games
        @games ||= Games.new(self, nil)
      end

      def plays
        @plays ||= Plays.new(self, nil)
      end

      def seasons
        @seasons ||= Seasons.new(self, nil)
      end

      def teams
        @teams ||= Teams.new(self, nil)
      end

      def populate!
        reset!
        game = Mock::Game.new_persistent
        games.save game
        plays.save({ game: game } => [ :jump_ball, team: :visitor, seconds: 1, teammate: 0, player: 0, opponent: 0 ])
        plays.save({ game: game, team: :visitor } => [ :fg, seconds: 19, player: 0 ])
        plays.save({ game: game, team: :visitor } => [ :fg, seconds: 8, player: 0 ])
        plays.save({ game: game, team: :visitor } => [ :fg, point_value: 3, seconds: 12, player: 1 ])
        plays.save({ game: game, team: :home } => [ :fg_miss, seconds: 4, player: 4 ])
        plays.save({ game: game, team: :visitor } => [ :fg_miss, seconds: 18, player: 0 ])
        plays.save({ game: game, team: :home } => [ :fg_miss, seconds: 17, player: 0 ])
        plays.save({ game: game, team: :visitor } => [ :fg_miss, seconds: 11, player: 0 ])
        plays.save({ game: game, team: :visitor } => [ :steal, seconds: 5, opponent: 0, player: 0 ])
        plays.save({ game: game, ball_in_play: true } => [ :rebound, team: :offense, player: 0, seconds: 1 ])
        plays.save({ game: game, ball_in_play: true } => [ :rebound, team: :defense, player: 0, seconds: 2 ])
        plays.save({ game: game, ball_in_play: true } => [ :rebound, team: :defense, player: 0, seconds: 0 ])
        plays.save({ game: game, ball_in_play: true } => [ :rebound, team: :defense, player: 0, seconds: 3 ])
        plays.save({ game: game, ball_in_play: true } => [ :period_end, seconds: 9 ])
      end

      def reset!
        games.games = []
        plays.sample_plays = []
        teams.teams = []
      end

      class Games < RepositoryModule::Base
        attr_writer :games

        def all
          games
        end

        def games
          @games ||= []
        end

        def save(game)
          games << game
          game.home = repository.teams.first_or_create(game.home)
          game.visitor = repository.teams.first_or_create(game.visitor)
        end
      end

      class Plays < RepositoryModule::Base
        attr_writer :sample_plays

        def count(possession_key, _team, _team_id, play)
          sample_plays.count do |a|
            if play.size > 1 && play.last[:team]
              a.possession_key == possession_key && a.key == play && a.team == play.last[:team]
            else
              a.possession_key == possession_key && a.key == play
            end
          end
        end

        def sample_plays
          @sample_plays ||= []
        end

        def save(hash)
          sample_plays << Persistent::Play.from_hash(hash)
        end

        # Incorrectly ignore play team
        def seconds_counts(play_key, _team, _team_id)
          sample_plays
            .select { |play| play.key == play_key }
            .group_by(&:seconds)
            .map { |count, play| { count: count, seconds: play.first.seconds } }
        end
      end

      class Seasons < RepositoryModule::Base
        def save(season)
          season.days.flat_map(&:games).each do |game|
            repository.games.save game
          end
        end
      end

      class Teams < RepositoryModule::Base
        attr_writer :teams

        def first_or_create(team)
          raise("Team abbreviation can't be nil") unless team.abbreviation

          existing_team = teams.detect { |t| t.abbreviation == team.abbreviation }
          return existing_team if existing_team

          team.id = teams.size
          teams << team
          team
        end

        def teams
          @teams ||= []
        end
      end
    end
  end
end
