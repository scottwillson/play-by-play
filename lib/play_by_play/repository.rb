require "pg"
require "sequel"
require "play_by_play/persistent/play"
require "play_by_play/repository/games"
require "play_by_play/repository/league"
require "play_by_play/repository/plays"
require "play_by_play/repository/possessions"
require "play_by_play/repository/rows"
require "play_by_play/repository/schema"
require "play_by_play/repository/teams"

module PlayByPlay
  class Repository
    attr_reader :environment

    def initialize(environment = PlayByPlay.environment)
      @environment = environment

      if environment == :test
        @db = ::Sequel.connect("postgres://localhost/play_by_play_test")
      else
        @db = ::Sequel.connect("postgres://localhost/play_by_play_development")
      end

      @db.extension :pagination
    end

    def games
      @games ||= RepositoryModule::Games.new(self, @db)
    end

    def league
      @league ||= RepositoryModule::League.new(self, @db)
    end

    def plays
      @plays ||= RepositoryModule::Plays.new(self, @db)
    end

    def possessions
      @possessions ||= RepositoryModule::Possessions.new(self, @db)
    end

    def rows
      @rows ||= RepositoryModule::Rows.new(self, @db)
    end

    def schema
      @schema ||= RepositoryModule::Schema.new(self, @db)
    end

    def teams
      @teams ||= RepositoryModule::Teams.new(self, @db)
    end

    def reset!
      if @db.table_exists?(:possessions)
        schema.truncate
      else
        create!
      end
    end

    def create
      schema.create
    end

    def create!
      schema.create true
    end
  end
end
