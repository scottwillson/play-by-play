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

    def count_plays(possession, defense_id, home_id, offense_id, visitor_id, play)
      play_attributes = {}
      if play.size > 1
        play_attributes = play.last.dup
      end

      play_team = play_attributes.delete(:team)

      query = @db[:plays]
        .join(:possessions, id: :possession_id)
        .where(
          and_one: play_attributes[:and_one] || false,
          assisted: play_attributes[:assisted] || false,
          away_from_play: play_attributes[:away_from_play] || false,
          clear_path: play_attributes[:clear_path] || false,
          flagrant: play_attributes[:flagrant] || false,
          intentional: play_attributes[:intentional] || false,
          type: play.first.to_s
        )

      if play_attributes[:point_value]
        query = query.where(point_value: play_attributes[:point_value])
      end

      if play_team
        query = query.where(plays__team: play_team.to_s)
      end

      if possession.technical_free_throws?
        query = query.where(technical_free_throws: true)
      elsif possession.free_throws?
        query = query.where(technical_free_throws: false, free_throws: true)
      elsif possession.team?
        query = query.where(technical_free_throws: false, free_throws: false, possessions__team: true)
      elsif possession.ball_in_play?
        query = query.where(technical_free_throws: false, free_throws: false, possessions__team: false, ball_in_play: true)
      elsif !possession.seconds_remaining?
        query = query.where(technical_free_throws: false, free_throws: false, possessions__team: false, ball_in_play: false, seconds_remaining: 0)
      else
        query = query.where(technical_free_throws: false, free_throws: false, possessions__team: false, ball_in_play: false)
        query = query.where("seconds_remaining > 0")
      end

      if possession.offense
        query = query.where("possessions.defense_id = ? or possessions.offense_id = ?", defense_id, offense_id)
      else
        query = query.where("possessions.home_id = ? or possessions.visitor_id = ?", home_id, visitor_id)
      end

      if play_attributes[:team]
        query = query.where(plays__team: play_attributes[:team].to_s)
      end

      # puts query.sql

      query.count
    end

    def save_plays(plays)
      plays.each { |play| save_play(play) }
    end

    def save_play(play)
      attributes = {
        possession_id: play.possession.id,
        team: play.team.to_s,
        and_one: play.and_one?,
        assisted: play.assisted?,
        away_from_play: play.away_from_play?,
        clear_path: play.clear_path?,
        flagrant: play.flagrant?,
        intentional: play.intentional?,
        type: play.type.to_s
      }

      if play.point_value == 3
        attributes = attributes.merge(point_value: 3)
      end

      play.id = @db[:plays].insert(attributes)
      update_row play.row, play.id
    end

    def save_possessions(game)
      game.possessions.each do |possession|
        possession.game = game
        save_possession possession
      end
    end

    def save_possession(possession)
      possession.id = @db[:possessions].insert(
        ball_in_play: possession.ball_in_play?,
        defense_id: possession.defense_id,
        free_throws: possession.free_throws?,
        game_id: possession.game_id,
        home_id: possession.game.home_id,
        next_team: possession.next_team.to_s,
        offense: possession.offense.to_s,
        offense_id: possession.offense_id,
        opening_tip: possession.opening_tip.to_s,
        period: possession.period,
        seconds_remaining: possession.seconds_remaining,
        team: possession.team?,
        technical_free_throws: possession.technical_free_throws?,
        visitor_id: possession.game.visitor_id
      )
    end

    def update_possession(possession, play_id)
      return unless possession && play_id
      @db[:possessions].where(id: possession.id).update(play_id: play_id)
      true
    end

    def save_game(game)
      game.home = create_team(game.home)
      game.visitor = create_team(game.visitor)

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
        attributes.delete(:defense_id)
        attributes.delete(:home_id)
        attributes.delete(:offense_id)
        attributes.delete(:visitor_id)

        [ :next_team, :offense, :opening_tip ].each do |key|
          if attributes[key] && attributes[key] != ""
            attributes[key] = attributes[key].to_sym
          else
            attributes[key] = nil
          end
        end

        if attributes[:team]
          attributes[:team] = attributes[:offense]
        else
          attributes[:team] = nil
        end

        if attributes[:free_throws]
          attributes[:free_throws] = [ attributes[:offense] ]
        else
          attributes[:free_throws] = []
        end

        if attributes[:technical_free_throws]
          attributes[:technical_free_throws] = [ attributes[:offense] ]
        else
          attributes[:technical_free_throws] = []
        end

        Persistent::Possession.new(attributes)
      end
    end

    def game_plays(game_id)
      @db[:plays]
        .select(:plays__id, :and_one, :assisted, :away_from_play, :clear_path, :flagrant, :intentional, :point_value, :possession_id, :plays__team, :type)
        .join(:possessions, id: :possession_id)
        .where(possessions__game_id: game_id)
        .map do |attributes|
          type = attributes.delete(:type)
          if type && type != ""
            type = type.to_sym
          else
            type = nil
          end
          Persistent::Play.new(type, attributes)
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

    def team_by_abbrevation(abbreviation)
      Persistent::Team.new @db[:teams].where(abbreviation: abbreviation).first
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
