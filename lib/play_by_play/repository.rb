require "sequel"
require "play_by_play/persistent/play"

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

      query = sample_play_query(play_attributes, play.first, possession_key)
      @db[:sample_plays].where(query).count
    end

    def save_sample_plays(plays)
      plays.each { |play| save_sample_play(play) }
    end

    def save_sample_play(play)
      play = Persistent::Play.from_hash(play)
      play_attributes = {}

      if play.key.size > 1
        play_attributes = play.key.last
      end

      query = sample_play_query(play_attributes, play.key.first, play.possession_key)
      id = @db[:sample_plays].insert(query)
      update_row(play.row, id)
    end

    def sample_play_query(play_attributes, key, possession_key)
      {
        possession_key: possession_key.to_s,
        team: play_attributes[:team]&.to_s,
        and_one: play_attributes[:and_one] || false,
        assisted: play_attributes[:assisted] || false,
        clear_path: play_attributes[:clear_path] || false,
        flagarant: play_attributes[:flagarant] || false,
        intentional: play_attributes[:intentional] || false,
        point_value: play_attributes[:point_value],
        type: key.to_s
      }
    end

    def save_sample_game(file)
      @db[:sample_games].insert(
        errors: file.errors,
        error_eventnum: file.error_eventnum,
        nba_game_id: file.nba_game_id,
        home_team_name: file.home_team_name,
        visitor_team_name: file.visitor_team_name
      )
    end

    def sample_games(page = 1)
      @db[:sample_games].exclude(error_eventnum: nil).paginate(page, 20).all
    end

    def rows(nba_game_id)
      sample_game_id = @db[:sample_games].where(nba_game_id: nba_game_id).first[:id]
      @db[:rows].where(sample_game_id: sample_game_id).all
    end

    def save_rows(rows)
      columns = [
        :play_id,
        :sample_game_id,
        :eventmsgactiontype,
        :eventmsgtype,
        :eventnum,
        :homedescription,
        :neutraldescription,
        :pctimestring,
        :period,
        :person1type,
        :person2type,
        :person3type,
        :player1_id,
        :player1_name,
        :player1_team_abbreviation,
        :player1_team_city,
        :player1_team_id,
        :player1_team_nickname,
        :player2_id,
        :player2_name,
        :player2_team_abbreviation,
        :player2_team_city,
        :player2_team_id,
        :player2_team_nickname,
        :player3_id,
        :player3_name,
        :player3_team_abbreviation,
        :player3_team_city,
        :player3_team_id,
        :player3_team_nickname,
        :score,
        :scoremargin,
        :visitordescription,
        :wctimestring
      ]

      values = rows.map do |row|
        [
          row.play_id,
          row.game.id,
          row.eventmsgactiontype,
          row.eventmsgtype,
          row.eventnum,
          row.homedescription,
          row.neutraldescription,
          row.pctimestring,
          row.period,
          row.person1type,
          row.person2type,
          row.person3type,
          row.player1_id,
          row.player1_name,
          row.player1_team_abbreviation,
          row.player1_team_city,
          row.player1_team_id,
          row.player1_team_nickname,
          row.player2_id,
          row.player2_name,
          row.player2_team_abbreviation,
          row.player2_team_city,
          row.player2_team_id,
          row.player2_team_nickname,
          row.player3_id,
          row.player3_name,
          row.player3_team_abbreviation,
          row.player3_team_city,
          row.player3_team_id,
          row.player3_team_nickname,
          row.score,
          row.scoremargin,
          row.visitordescription,
          row.wctimestring
        ]
      end

      @db[:rows].import columns, values
    end

    def update_row(row, play_id)
      return unless row && play_id
      @db[:rows].where(id: row.id).update(play_id: play_id)
      true
    end

    def sample_league
      league = Sample::League.new(id: @db[:sample_leagues].first[:id])

      # TODO use a join!
      @db[:sample_conferences].where(sample_league_id: league.id).each do |conference_attributes|
        conference = Persistent::Conference.new(id: conference_attributes[:id], name: conference_attributes[:name], league_id: league.id)
        league.conferences << conference

        @db[:sample_divisions].where(sample_conference_id: conference.id).each do |division_attributes|
          division = Persistent::Division.new(id: division_attributes[:id], name: division_attributes[:name], conference_id: conference.id)
          conference.divisions << division

          @db[:sample_teams].where(sample_division_id: division.id).each do |team_attributes|
            team = Persistent::Team.new(id: team_attributes[:id], name: team_attributes[:name], division_id: division.id)
            division.teams << team
          end
        end
      end

      league
    end

    def sample_league?
      @db[:sample_leagues].first != nil
    end

    def save_sample_league(league)
      league.id = @db[:sample_leagues].insert
      league.conferences.each do |conference|
        conference.id = @db[:sample_conferences].insert(sample_league_id: league.id, name: conference.name)
        conference.divisions.each do |division|
          division.id = @db[:sample_divisions].insert(sample_conference_id: conference.id, name: division.name)
          division.teams.each do |team|
            team.id = @db[:sample_teams].insert(sample_division_id: division.id, name: team.name)
          end
        end
      end
      true
    end

    def reset!
      if @db.table_exists?(:sample_plays)
        @db[:sample_conferences].truncate
        @db[:sample_divisions].truncate
        @db[:sample_leagues].truncate
        @db[:sample_teams].truncate
        @db[:sample_plays].truncate
        @db[:sample_games].truncate
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
      @db.send(create_table_method, :sample_plays) do
        primary_key :id
        Boolean :and_one, default: false
        Boolean :assisted, default: false
        Boolean :clear_path, default: false
        Boolean :flagarant, default: false
        Boolean :intentional, default: false
        Integer :point_value
        String :possession_key, null: false
        String :team
        String :type
        index :possession_key
      end

      @db.send(create_table_method, :sample_games) do
        primary_key :id
        Integer :nba_game_id
        String :errors
        Integer :error_eventnum
        String :home_team_name
        String :visitor_team_name
        index :error_eventnum
        index :nba_game_id
      end

      @db.send(create_table_method, :sample_conferences) do
        primary_key :id
        String :name
        Integer :sample_league_id
      end

      @db.send(create_table_method, :sample_divisions) do
        primary_key :id
        String :name
        Integer :sample_conference_id
      end

      @db.send(create_table_method, :sample_leagues) do
        primary_key :id
        String :name
      end

      @db.send(create_table_method, :sample_teams) do
        primary_key :id
        String :name
        Integer :sample_division_id
      end

      @db.send(create_table_method, :rows) do
        primary_key :id
        Integer :sample_game_id
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
        index :sample_game_id
        index :play_id
      end
    end
  end
end
