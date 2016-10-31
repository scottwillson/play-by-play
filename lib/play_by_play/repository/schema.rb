require "play_by_play/repository/base"

module PlayByPlay
  module RepositoryModule
    class Schema < Base
      def create(reset = false)
        create_table_method = reset ? :create_table! : :create_table?

        db.send(create_table_method, :conferences) do
          primary_key :id
          String :name, unique: true
          Integer :league_id
        end

        db.send(create_table_method, :divisions) do
          primary_key :id
          String :name, unique: true
          Integer :conference_id
        end

        db.send(create_table_method, :games) do
          primary_key :id
          String :errors
          Integer :error_eventnum
          Integer :home_id
          String :nba_id, unique: true
          Integer :visitor_id
          index :error_eventnum
          index :home_id
          index :nba_id
          index :visitor_id
        end

        db.send(create_table_method, :leagues) do
          primary_key :id
          String :name, unique: true
        end

        db.send(create_table_method, :plays) do
          primary_key :id
          Boolean :and_one, default: false, null: false
          Boolean :assisted, default: false, null: false
          Boolean :away_from_play, default: false, null: false
          Boolean :clear_path, default: false, null: false
          Boolean :flagrant, default: false, null: false
          Boolean :intentional, default: false, null: false
          Integer :point_value
          Integer :possession_id, null: false
          String :team
          String :type
          index :possession_id
          index :team
          index :type
          index [ :and_one, :assisted, :away_from_play, :clear_path, :flagrant, :intentional, :team ]
        end

        db.send(create_table_method, :possessions) do
          primary_key :id
          Boolean :ball_in_play, default: false, null: false
          Integer :defense_id
          Boolean :free_throws, default: false, null: false
          Integer :game_id, null: false
          Integer :home_id, null: false
          String :next_team
          String :offense
          Integer :offense_id
          String :opening_tip
          Integer :period, null: false
          Integer :seconds_remaining, null: false
          Boolean :team, default: false, null: false
          Boolean :technical_free_throws, default: false, null: false
          Integer :visitor_id, null: false
          index :defense_id
          index :game_id
          index :home_id
          index :offense_id
          index :visitor_id
          index [ :technical_free_throws, :free_throws, :team, :ball_in_play, :seconds_remaining, :home_id, :visitor_id ]
        end

        db.send(create_table_method, :rows) do
          primary_key :id
          Integer :game_id
          Integer :play_id
          Integer :eventmsgactiontype
          Integer :eventmsgtype
          Integer :eventnum
          String :homedescription
          String :neutraldescription
          String :pctimestring
          Integer :period
          Integer :person1type
          Integer :person2type
          Integer :person3type
          Integer :player1_id
          String :player1_name
          String :player1_team_abbreviation
          String :player1_team_city
          Integer :player1_team_id
          String :player1_team_nickname
          Integer :player2_id
          String :player2_name
          String :player2_team_abbreviation
          String :player2_team_city
          Integer :player2_team_id
          String :player2_team_nickname
          Integer :player3_id
          String :player3_name
          String :player3_team_abbreviation
          String :player3_team_city
          Integer :player3_team_id
          String :player3_team_nickname
          String :score
          Integer :scoremargin
          String :visitordescription
          String :wctimestring
          index :game_id
          index :play_id
        end

        db.send(create_table_method, :teams) do
          primary_key :id
          String :abbreviation, unique: true
          String :name, unique: true
          Integer :division_id
          index :abbreviation
        end
      end

      def truncate
        @db[:conferences].truncate
        @db[:divisions].truncate
        @db[:games].truncate
        @db[:leagues].truncate
        @db[:plays].truncate
        @db[:possessions].truncate
        @db[:rows].truncate
        @db[:teams].truncate
      end
    end
  end
end
