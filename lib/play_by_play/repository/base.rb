module PlayByPlay
  module RepositoryModule
    class Base
      attr_reader :db, :repository

      def initialize(repository, db)
        @db = db
        @repository = repository
      end
    end
  end
end
