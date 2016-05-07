 * Rename nba_game_id to nba_id
 * GamePlay#play! should only accept Play key, not a Play?
 * Use better Rspec predicate matchers
 * Sample:Schedule
 * Test season simulation with database
 * Refactor season simulation to be more like Redux
 * Add sequence number to row? (or just rely on ID)
 * better favicon
 * change model initialize to *attribute?
 * cache attributes?
 * rebound must come after miss. Need to validate?
 * recovered blocks are always rebounds?
 * blocks should go out of bounds (this could be a team rebound?)
 * need different probabilities after a block than after a rebound
 * consider log5 https://web.archive.org/web/20140123014747/http://www.chancesis.com/2010/10/03/the-origins-of-log5
 * validate game state against state in historical row
 * Overtime is not considered an extension of any quarter. Instead, the "penalty" of two free throws is triggered on the team's fourth foul in that overtime period (instead of the fifth).
 * Simulation should only consider time remaining when choosing :period_end
 * Double personal fouls shall add to a player's total, but not to the team total.
 * validate seconds_remaining when importing sample
 * do imports concurrently
 * Add view for probability distribution
 * bulk insert plays
 * Add missing FT play to 0021400052
 * Random season schedule shouldn't allow teams to play multiple gams per day
 * Show errors in web UI
 * Move InvalidStateError out of Model
 * PlayByPlay::Model::Duplication#attributes is slow
 * Freeze new models
 * Code called in Rake tasks shouldn't need setup
 * use a join in Repository#league
