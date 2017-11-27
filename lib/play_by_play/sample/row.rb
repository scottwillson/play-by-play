require "play_by_play/model/invalid_state_error"

module PlayByPlay
  module Sample
    class Row
      ACTION_MAP = {
        1 => :fg,
        2 => :fg_miss,
        3 => :ft,
        4 => :rebound,
        5 => :turnover,
        6 => :foul,
        7 => :defensive_violation,
        8 => :substitution,
        9 => :timeout,
        10 => :jump_ball,
        11 => :ejection,
        12 => :period_start,
        13 => :period_end,
        18 => :unknown,
        116 => :delay_of_game_technical
      }.freeze

      attr_accessor :id
      attr_accessor :possession_id
      attr_accessor :eventmsgactiontype
      attr_accessor :eventmsgtype
      # *Not* in exact chronological order
      attr_accessor :eventnum
      attr_accessor :homedescription
      attr_accessor :neutraldescription
      attr_accessor :pctimestring
      attr_accessor :period
      attr_accessor :person1type
      attr_accessor :person2type
      attr_accessor :person3type
      attr_accessor :game
      attr_accessor :nba_id
      attr_accessor :player1_id
      attr_accessor :player1_name
      attr_accessor :player1_team_abbreviation
      attr_accessor :player1_team_city
      attr_accessor :player1_team_id
      attr_accessor :player1_team_nickname
      attr_accessor :player2_id
      attr_accessor :player2_name
      attr_accessor :player2_team_abbreviation
      attr_accessor :player2_team_city
      attr_accessor :player2_team_id
      attr_accessor :player2_team_nickname
      attr_accessor :player3_id
      attr_accessor :player3_name
      attr_accessor :player3_team_abbreviation
      attr_accessor :player3_team_city
      attr_accessor :player3_team_id
      attr_accessor :player3_team_nickname
      attr_accessor :possession
      attr_accessor :score
      attr_accessor :visitordescription
      attr_accessor :wctimestring

      attr_writer :scoremargin

      def initialize(game, headers, json)
        @game = game
        @game.rows << self

        json.each.with_index do |cell, index|
          send "#{headers[index].downcase}=", cell
        end
      end

      def and_one?
        fg? && next_row&.shooting_foul? && next_row&.team != team
      end

      def at_basket?
        (fg? || miss?) && [ 4, 5, 7, 72, 87, 92 ].include?(eventmsgactiontype)
      end

      def away_from_play?
        foul? && eventmsgactiontype == 6
      end

      def description
        [ homedescription, visitordescription ].compact.join(" ").strip
      end

      def event
        ACTION_MAP[eventmsgtype]
      end

      def assist?
        fg? && player2_id && player2_id > 0
      end

      def block?
        fg_miss? && description["BLOCK"]
      end

      def personal_foul?
        return unless foul?

        # 25 is 'taking' a foul to stop clock
        [ 1, 3, 5, 6, 9, 25, 27, 28 ].include?(eventmsgactiontype)
      end

      def flagrant?
        foul? && eventmsgactiontype == 14
      end

      def fg?
        event == :fg
      end

      def fg_miss?
        event == :fg_miss
      end

      def foul?
        event == :foul
      end

      def ft?
        event == :ft && !description["MISS"]
      end

      def ft_miss?
        event == :ft && description["MISS"]
      end

      def game_id=(value)
        @nba_id = value
      end

      def clear_path_foul?
        foul? && eventmsgactiontype == 9
      end

      def intentional?
        (foul? && eventmsgactiontype == 5)
      end

      def jump_ball?
        event == :jump_ball
      end

      def miss?
        fg_miss? || ft_miss?
      end

      def next_row
        @next_row ||= rows[rows.find_index(self) + 1]
      end

      def offensive_foul?
        return unless foul?
        return unless possession.offense == team

        [ 4, 26 ].include?(eventmsgactiontype)
      end

      def offensive_foul_turnover?
        turnover? && (eventmsgactiontype == 5 || eventmsgactiontype == 37)
      end

      def misidentified_shooting_foul?
        personal_foul? && !Model::GamePlay.next_foul_in_penalty?(possession, team) && next_row.event == :ft
      end

      def period_end?
        event == :period_end
      end

      def period_start?
        event == :period_start
      end

      def point_value
        if ft? || ft_miss?
          1
        elsif three_point?
          3
        elsif fg? || fg_miss?
          2
        elsif shooting_foul? && three_free_throws?
          3
        elsif shooting_foul?
          2
        end
      end

      def previous_row
        if rows
          @previous_row ||= rows[rows.find_index(self) - 1]
        end
      end

      def rebound?
        event == :rebound
      end

      def rows
        game.rows
      end

      def scoremargin
        @scoremargin.to_i
      end

      def seconds
        if possession.seconds_remaining.nil?
          0
        elsif next_row&.period_end?
          possession.seconds_remaining
        else
          possession.seconds_remaining - seconds_remaining
        end
      end

      def seconds_remaining
        return unless pctimestring

        minutes, seconds = pctimestring.split(":")
        minutes.to_i * 60 + seconds.to_i
      end

      def shooting_foul?
        foul? && (eventmsgactiontype == 2 || eventmsgactiontype == 29 || (away_from_play? && previous_row&.fg? && previous_row.team != team))
      end

      def start_of_game?
        eventnum == 0
      end

      # "STEAL" seeems to be the only thing that matters
      def steal?
        event == :turnover && [ 0, 1, 2, 41 ].include?(eventmsgactiontype) && description["STEAL"]
      end

      def substitution?
        event == :substitution
      end

      def team_rebound?
        rebound? && (person1type == 2 || person1type == 3)
      end

      def technical_foul?
        foul? && ((eventmsgactiontype > 9 && eventmsgactiontype <= 19) || eventmsgactiontype == 30 || eventmsgactiontype == 267)
      end

      def double_technical_foul?
        foul? && (eventmsgactiontype == 10 || eventmsgactiontype == 16)
      end

      def technical_ft?
        ft? && eventmsgactiontype >= 16
      end

      def technical_ft_miss?
        ft_miss? && eventmsgactiontype >= 16
      end

      def timeout?
        event == :timeout
      end

      def three_free_throws?
        index = 1
        while (row = rows[rows.find_index(self) + index])
          if row.ft? || row.ft_miss?
            if row.eventmsgactiontype == 13
              return true
            else
              return false
            end
          end

          index += 1
        end
      end

      def three_point?
        description["3PT"]
      end

      def three_point_fg?
        fg? && three_point?
      end

      def three_point_fg_miss?
        fg_miss? && three_point?
      end

      def turnover?
        event == :turnover
      end

      # FT miss with more FTs upcoming count as team rebounds (doesn't count in stats)
      # Block + ball out of bounds off shooter: team rebounds
      # Missed shot + out of bounds off other team
      # Missed live FT  + out of bounds off other team
      # Missed shot at end of period
      def uncounted_team_rebound?(possession)
        team_rebound? && (possession.free_throws? || possession.seconds_remaining == 720 || previous_row&.technical_ft_miss?)
      end

      def play_type
        if start_of_game?
          nil
        elsif jump_ball?
          :jump_ball
        elsif block?
          :block
        elsif fg_miss?
          :fg_miss
        elsif team_rebound?
          :team_rebound
        elsif rebound?
          :rebound
        elsif fg?
          :fg
        elsif ft? || technical_ft?
          :ft
        elsif ft_miss? || technical_ft_miss?
          :ft_miss
        elsif steal?
          :steal
        elsif turnover?
          :turnover
        elsif shooting_foul?
          :shooting_foul
        elsif double_technical_foul?
          :double_technical_foul
        elsif technical_foul?
          :technical_foul
        elsif personal_foul?
          :personal_foul
        elsif offensive_foul?
          :offensive_foul
        elsif period_end?
          :period_end
        elsif timeout? || substitution? || [ :unknown, :defensive_violation, :ejection, :period_start ].include?(event)
          nil
        else
          raise "Could not parse Model::Play#type for #{self}"
        end
      end

      def play_attributes
        {
          and_one: and_one?,
          assisted: assist?,
          away_from_play: away_from_play?,
          clear_path: clear_path_foul?,
          flagrant: flagrant?,
          intentional: intentional?,
          point_value: point_value,
          seconds: seconds,
          shot: shot,
          team: play_team
        }
      end

      def play_team
        if turnover? && possession.team
          return nil
        end

        if rebound? || (technical_foul? && possession&.offense) || personal_foul? || (jump_ball? && possession&.offense && possession&.team)
          if team == possession.offense
            :offense
          else
            :defense
          end
        else
          team
        end
      end

      def player_attributes
        [
          [ person1type, player1_id, player1_name ],
          [ person2type, player2_id, player2_name ],
          [ person3type, player3_id, player3_name ]
        ]
      end

      def shot
        if fg?
          if team == :home
            game.home.players.index { |player| player.nba_id == player1_id }
          else
            game.visitor.players.index { |player| player.nba_id == player1_id }
          end
        end
      end

      def team
        if person3type && person3type > 1
          person_type = person3type
        else
          person_type = person1type
        end

        case person_type
        when 0, 2, 4, 6
          :home
        when 1, 3, 5, 7
          :visitor
        end
      end

      def to_s
        instance_variables
          .reject { |v| [ :@game, :@next_row, :@previous_row, :@possession ].include?(v) }
          .map { |v| [ v, send(v.to_s.delete("@")) ] }
          .to_h
          .inspect
      end
    end
  end
end
