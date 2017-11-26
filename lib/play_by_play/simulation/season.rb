require "play_by_play/model/invalid_state_error"
require "play_by_play/persistent/day"
require "play_by_play/persistent/game"
require "play_by_play/persistent/season"
require "play_by_play/persistent/team"
require "play_by_play/repository"
require "play_by_play/simulation/game"
require "play_by_play/simulation/league"
require "play_by_play/simulation/random_play_generator"

module PlayByPlay
  module Simulation
    module Season
      def self.new_persistent(**args)
        raise(ArgumentError("source must be unspecified")) if args[:source]
        args[:source] = "simulation"
        Persistent::Season.new args
      end

      def self.new_random(league: League.new_random(30), scheduled_games_per_teams_count: 82)
        scheduled_games_per_teams_count = scheduled_games_per_teams_count.to_i

        PlayByPlay.logger.debug(simulation_season: :new_random, begin: Time.now)

        raise(Model::InvalidStateError, "scheduled_games_per_teams_count must be even but was #[scheduled_games_per_teams_count]") if scheduled_games_per_teams_count.odd?

        season = new_persistent(league: league)

        scheduled_games_count = season.teams.size * (scheduled_games_per_teams_count / 2)
        create_days season, scheduled_games_count, scheduled_games_per_teams_count

        season.teams.each do |team|
          if scheduled_games_per_teams_count != team.games.size
            raise(Model::InvalidStateError, "#{team.name} has #{team.games.size} instead of #{scheduled_games_per_teams_count}")
          end
        end

        PlayByPlay.logger.debug(simulation_season: :new_random, end: Time.now)

        season
      end

      def self.play!(days: nil, season: Season.new_random, repository: Repository.new, random_play_generator: RandomPlayGenerator.new(repository), random_seconds_generator: RandomSecondsGenerator.new(repository))
        PlayByPlay.logger.debug(simulation_season: :play!, begin: Time.now)

        if days
          days = season.days[0, days]
        else
          days = season.days
        end

        days
          .map { |day| play_day! day, random_play_generator, random_seconds_generator }
          .each(&:join)

        PlayByPlay.logger.debug(simulation_season: :play!, end: Time.now)

        season
      end

      def self.create_days(season, scheduled_games_count, scheduled_games_per_teams_count)
        date = Date.today
        while season.games.size < scheduled_games_count
          games_to_go = scheduled_games_count - season.games.size
          if games_to_go > 12
            number_of_games = rand(12) + 1
          else
            number_of_games = games_to_go
          end

          day = Persistent::Day.new(date: date += 1, season: season)
          create_games season, day, scheduled_games_per_teams_count, number_of_games
        end
      end

      def self.create_games(season, day, scheduled_games_per_teams_count, number_of_games)
        teams = season.teams.select { |team| team.games.size < scheduled_games_per_teams_count }
                      .shuffle
                      .sort_by { |team| team.games.size }

        raise(Model::InvalidStateError, "All teams have played #{scheduled_games_per_teams_count} games") if teams.empty?
        raise(Model::InvalidStateError, "Only #{teams.first.name} has played fewer than #{scheduled_games_per_teams_count} games") if teams.size == 1

        if number_of_games > teams.size / 2
          number_of_games = teams.size / 2
        end

        number_of_games.times do
          raise(Model::InvalidStateError, "All teams have played #{scheduled_games_per_teams_count} games") if teams.empty?
          raise(Model::InvalidStateError, "Only #{teams.first.name} has played fewer than #{scheduled_games_per_teams_count} games") if teams.size == 1
          home = teams.pop
          visitor = teams.pop
          game = Persistent::Game.new(day: day, home: home, visitor: visitor)
          home.games << game
          visitor.games << game
        end
      end

      def self.play_day!(day, random_play_generator, random_seconds_generator)
        Thread.new do
          day.games.each do |game|
            Simulation::Game.play! game, random_play_generator, random_seconds_generator
          end
        end
      end
    end
  end
end
