# rubocop:disable Metrics/AbcSize, Metrics/MethodLength

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

        db.send(create_table_method, :days) do
          primary_key :id
          Date :date, unique: true
          Integer :season_id, null: false
          index :date
          index :season_id
        end

        db.send(create_table_method, :divisions) do
          primary_key :id
          String :name, unique: true
          Integer :conference_id
        end

        db.send(create_table_method, :games) do
          primary_key :id
          Integer :day_id, null: false
          String :errors
          Integer :error_eventnum
          Integer :home_id
          String :nba_id, unique: true
          Integer :visitor_id
          index :day_id
          index :error_eventnum
          index :home_id
          index :nba_id
          index :visitor_id
        end

        db.send(create_table_method, :leagues) do
          primary_key :id
          String :name, unique: true
        end

        db.send(create_table_method, :possessions) do
          primary_key :id
          Boolean :and_one, default: false, null: false
          Boolean :assisted, default: false, null: false
          Boolean :away_from_play, default: false, null: false
          Boolean :clear_path, default: false, null: false
          Boolean :flagrant, default: false, null: false
          Boolean :intentional, default: false, null: false
          Integer :point_value
          String :play_team
          String :play_type
          Integer :seconds
          Integer :shot

          Boolean :ball_in_play, default: false, null: false
          Integer :defense_id
          Boolean :free_throws, default: false, null: false
          Integer :game_id, null: false
          Integer :home_id, null: false
          Integer :home_margin, null: false, default: 0
          String :next_team
          String :offense
          Integer :offense_id
          String :opening_tip
          Integer :period, null: false
          Integer :seconds_remaining, null: false
          String :source, null: false
          Boolean :team, default: false, null: false
          Boolean :technical_free_throws, default: false, null: false
          Integer :visitor_id, null: false
          Integer :visitor_margin, null: false, default: 0
          index :defense_id
          index :game_id
          index :home_id
          index :offense_id
          index :visitor_id
          index %i[ technical_free_throws free_throws team ball_in_play seconds_remaining home_id visitor_id ]

          index :play_team
          index :play_type
          index %i[ and_one assisted away_from_play clear_path flagrant intentional play_team ]
        end

        db.send(create_table_method, :seasons) do
          primary_key :id
          String :source, null: false
          Date :start_at, null: false
          index :source
          index :start_at
        end

        db.send(create_table_method, :rows) do
          primary_key :id
          Integer :game_id
          Integer :possession_id
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
          index :possession_id
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
        @db[:days].truncate
        @db[:divisions].truncate
        @db[:games].truncate
        @db[:leagues].truncate
        @db[:possessions].truncate
        @db[:seasons].truncate
        @db[:rows].truncate
        @db[:teams].truncate
      end
    end
  end
end
