module PlayByPlay
  module Model
    module GamePlay
      def self.period_end(possession, _)
        {
          ball_in_play: false,
          home: possession.home.merge(period_personal_fouls: 0, personal_foul_in_last_two_minutes: false),
          offense: nil,
          period: next_period(possession),
          seconds_remaining: next_period_seconds_remaining(possession),
          team: next_period_team(possession),
          visitor: possession.visitor.merge(period_personal_fouls: 0, personal_foul_in_last_two_minutes: false)
        }
      end

      def self.next_period(possession)
        if possession.period < 4 || possession.tied?
          possession.period + 1
        else
          possession.period
        end
      end

      def self.next_period_seconds_remaining(possession)
        if possession.period < 4
          720
        elsif possession.tied?
          300
        else
          0
        end
      end

      def self.next_period_team(possession)
        case possession.period
        when 1, 2
          possession.other_team(possession.opening_tip)
        when 3
          possession.opening_tip
        end
      end
    end
  end
end
