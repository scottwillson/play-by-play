require "sequel"
require "play_by_play/sample/play"

module PlayByPlay
  class Repository
    def initialize(environment = PlayByPlay.environment)
      @environment = environment

      if environment == :test
        @db = ::Sequel.sqlite
      else
        @db = ::Sequel.connect("sqlite://play_by_play_development.db")
      end

      @db.extension :pagination
    end

    def count_plays(possession_key, play)
      play_attributes = {}
      if play.size > 1
        play_attributes = play.last
      end

      query = play_query(play_attributes, play.first, possession_key)
      @db[:plays].where(query).count
    end

    def save_sample_plays(plays)
      plays.each { |play| save_sample_play(play) }
    end

    def save_sample_play(play)
      play = Sample::Play.from_hash(play)
      play_attributes = {}

      if play.key.size > 1
        play_attributes = play.key.last
      end

      query = play_query(play_attributes, play.key.first, play.possession_key)
      id = @db[:plays].insert(query)
      update_row(play.row, id)
    end

    def play_query(play_attributes, key, possession_key)
      {
        ball_in_play: false,
        free_throws: false,
        seconds_remaining: true,
        team: false,
        technical_free_throws: false,
        play_team: play_attributes[:team]&.to_s,
        and_one: play_attributes[:and_one] || false,
        assisted: play_attributes[:assisted] || false,
        clear_path: play_attributes[:clear_path] || false,
        flagarant: play_attributes[:flagarant] || false,
        intentional: play_attributes[:intentional] || false,
        point_value: play_attributes[:point_value],
        type: key.to_s
      }.merge(possession_key)
    end

    def save_game(file)
      @db[:games].insert(
        errors: file.errors,
        error_eventnum: file.error_eventnum,
        game_id: file.game_id,
        home_team_name: file.home_team_name,
        visitor_team_name: file.visitor_team_name
      )
    end

    def games(page = 1)
      @db[:games].exclude(error_eventnum: nil).paginate(page, 20).all
    end

    def rows(game_id)
      game_id = @db[:games].where(game_id: game_id).first[:id]
      @db[:rows].where(game_id: game_id).all
    end

    def save_rows(rows)
      rows.each do |row|
        row.id = @db[:rows].insert(
          play_id: row.play_id,
          game_id: row.game.id,
          eventmsgactiontype: row.eventmsgactiontype,
          eventmsgtype: row.eventmsgtype,
          eventnum: row.eventnum,
          homedescription: row.homedescription,
          neutraldescription: row.neutraldescription,
          pctimestring: row.pctimestring,
          period: row.period,
          person1type: row.person1type,
          person2type: row.person2type,
          person3type: row.person3type,
          player1_id: row.player1_id,
          player1_name: row.player1_name,
          player1_team_abbreviation: row.player1_team_abbreviation,
          player1_team_city: row.player1_team_city,
          player1_team_id: row.player1_team_id,
          player1_team_nickname: row.player1_team_nickname,
          player2_id: row.player2_id,
          player2_name: row.player2_name,
          player2_team_abbreviation: row.player2_team_abbreviation,
          player2_team_city: row.player2_team_city,
          player2_team_id: row.player2_team_id,
          player2_team_nickname: row.player2_team_nickname,
          player3_id: row.player3_id,
          player3_name: row.player3_name,
          player3_team_abbreviation: row.player3_team_abbreviation,
          player3_team_city: row.player3_team_city,
          player3_team_id: row.player3_team_id,
          player3_team_nickname: row.player3_team_nickname,
          score: row.score,
          scoremargin: row.scoremargin,
          visitordescription: row.visitordescription,
          wctimestring: row.wctimestring
        )
      end
    end

    def update_row(row, play_id)
      return unless row && play_id
      @db[:rows].where(id: row.id).update(play_id: play_id)
      true
    end

    def reset!
      if @db.table_exists?(:plays)
        @db[:plays].truncate
        @db[:games].truncate
        @db[:rows].truncate
      else
        create!
      end
    end

    def create
      create_tables
    end

    def create!
      create_tables true
    end

    def create_tables(reset = false)
      create_table_method = reset ? :create_table! : :create_table?
      @db.send(create_table_method, :plays) do
        primary_key :id
        Boolean :ball_in_play, default: false
        Boolean :clear_path, default: false
        Boolean :flagarant, default: false
        Boolean :free_throws, default: false
        Boolean :intentional, default: false
        Boolean :seconds_remaining, default: true
        Boolean :team, default: false
        Boolean :technical_free_throws, default: false
        String :play_team
        Boolean :and_one, default: false
        Boolean :assisted, default: false
        Integer :point_value
        String :type
      end

      @db.send(create_table_method, :games) do
        primary_key :id
        Integer :game_id
        String :errors
        Integer :error_eventnum
        String :home_team_name
        String :visitor_team_name
        index :error_eventnum
        index :game_id
      end

      @db.send(create_table_method, :rows) do
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
    end
  end
end