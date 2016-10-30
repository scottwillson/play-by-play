require "pg"
require "sequel"
require "play_by_play/persistent/play"

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

    def count_plays(possession_key, play)
      play_attributes = {}
      if play.size > 1
        play_attributes = play.last
      end

      query = play_query(play_attributes, play.first, possession_key)
      @db[:plays].where(query).count
    end

    def save_plays(plays)
      plays.each { |play| save_play(play) }
    end

    def save_play(play)
      play = Persistent::Play.from_hash(play)
      play_attributes = {}

      if play.key.size > 1
        play_attributes = play.key.last
      end

      query = play_query(play_attributes, play.key.first, play.possession_key)
      id = @db[:plays].insert(query)
      update_row(play.row, id)
      update_possession(play.possession, id)
    end

    def play_query(play_attributes, key, possession_key)
      {
        possession_key: possession_key.to_s,
        team: play_attributes[:team]&.to_s,
        and_one: play_attributes[:and_one] || false,
        assisted: play_attributes[:assisted] || false,
        away_from_play: play_attributes[:away_from_play] || false,
        clear_path: play_attributes[:clear_path] || false,
        flagrant: play_attributes[:flagrant] || false,
        intentional: play_attributes[:intentional] || false,
        point_value: play_attributes[:point_value],
        type: key.to_s
      }
    end

    def save_possessions(game)
      game.possessions.each do |possession|
        possession.game_id = game.id
        save_possession possession
      end
    end

    def save_possession(possession)
      possession.id = @db[:possessions].insert(game_id: possession.game_id, play_id: possession.play_id)
    end

    def update_possession(possession, play_id)
      return unless possession && play_id
      @db[:possessions].where(id: possession.id).update(play_id: play_id)
      true
    end

    def save_game(game)
      game.id = @db[:games].insert(
        errors: game.errors,
        error_eventnum: game.error_eventnum,
        home_id: game.home.id,
        nba_id: game.nba_id,
        visitor_id: game.visitor.id
      )

      save_possessions game
      save_plays game.plays

      true
    end

    def game(id)
      attributes = @db[:games].where(id: id).first

      attributes[:home] = team(attributes[:home_id])
      attributes[:visitor] = team(attributes[:visitor_id])

      Persistent::Game.new attributes
    end

    def games(page = 1)
      @db[:games].exclude(error_eventnum: nil).paginate(page, 20).all
    end

    def game_possessions(game_id)
      @db[:possessions].where(game_id: game_id).map do |attributes|
        Persistent::Possession.new(attributes)
      end
    end

    def game_plays(game_id)
      @db[:plays].join(:possessions, play_id: :id).where(possessions__game_id: game_id).map do |attributes|
        attributes.delete(:game_id)
        attributes.delete(:play_id)
        attributes.delete(:possession_key)
        type = attributes.delete(:type)
        Persistent::Play.new(type.to_sym, attributes)
      end
    end

    def rows(nba_id)
      game_id = @db[:games].where(nba_id: nba_id).first[:id]
      @db[:rows].where(game_id: game_id).all
    end

    def save_rows(rows)
      columns = [
        :play_id,
        :game_id,
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

    def team(id)
      return unless id
      Persistent::Team.new @db[:teams].where(id: id).first
    end

    def create_team(team)
      raise(ArgumentError, "team cannot be nil") unless team
      raise(ArgumentError, "team must have name or abbreviation") if team.abbreviation.nil? && team.name.nil?
      return team if team.id

      attributes = @db[:teams].where(abbreviation: team.abbreviation, name: team.name).first
      return Persistent::Team.new(attributes) if attributes

      save_team team
    end

    def save_team(team)
      id = @db[:teams].insert(
        abbreviation: team.abbreviation,
        name: team.name
      )
      team.id = id
      team
    end

    def league
      league = Persistent::League.new(id: @db[:leagues].first[:id])

      @db[:conferences].where(league_id: league.id).each do |conference_attributes|
        conference = Persistent::Conference.new(id: conference_attributes[:id], name: conference_attributes[:name], league_id: league.id)
        league.conferences << conference

        @db[:divisions].where(conference_id: conference.id).each do |division_attributes|
          division = Persistent::Division.new(id: division_attributes[:id], name: division_attributes[:name], conference_id: conference.id)
          conference.divisions << division

          @db[:teams].where(division_id: division.id).each do |team_attributes|
            team = Persistent::Team.new(id: team_attributes[:id], name: team_attributes[:name], division_id: division.id)
            division.teams << team
          end
        end
      end

      league
    end

    def league?
      @db[:leagues].first != nil
    end

    def save_league(league)
      league.id = @db[:leagues].insert
      league.conferences.each do |conference|
        conference.id = @db[:conferences].insert(league_id: league.id, name: conference.name)
        conference.divisions.each do |division|
          division.id = @db[:divisions].insert(conference_id: conference.id, name: division.name)
          division.teams.each do |team|
            team.id = @db[:teams].insert(division_id: division.id, name: team.name)
          end
        end
      end
      true
    end

    def reset!
      if @db.table_exists?(:plays)
        @db[:conferences].truncate
        @db[:divisions].truncate
        @db[:games].truncate
        @db[:leagues].truncate
        @db[:plays].truncate
        @db[:possessions].truncate
        @db[:rows].truncate
        @db[:teams].truncate
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

      @db.send(create_table_method, :conferences) do
        primary_key :id
        String :name
        Integer :league_id
      end

      @db.send(create_table_method, :divisions) do
        primary_key :id
        String :name
        Integer :conference_id
      end

      @db.send(create_table_method, :games) do
        primary_key :id
        String :errors
        Integer :error_eventnum
        Integer :home_id
        String :nba_id
        Integer :visitor_id
        index :error_eventnum
        index :home_id
        index :nba_id
        index :visitor_id
      end

      @db.send(create_table_method, :leagues) do
        primary_key :id
        String :name
      end

      @db.send(create_table_method, :plays) do
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
      end

      @db.send(create_table_method, :possessions) do
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
        index :game_id
        index :home_id
        index :visitor_id
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

      @db.send(create_table_method, :teams) do
        primary_key :id
        String :abbreviation
        String :name
        Integer :division_id
        index :abbreviation
      end
    end
  end
end
