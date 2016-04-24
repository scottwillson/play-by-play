 * Play methods that only involve Possession should live on Possession
 * move to_visitor_or_home_symbol and other_team to GamePlay or shared module?
 * break apart play_spec and rename
 * rename Possession#to_visitor_or_home_symbol to #team_key ?
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
 * split import from parse so import can be run to check model
 * only persist after import(s)
 * do imports concurrently
 * Add view for probability distribution
 * Team#merge_team dupe of code in Duplication
 * bulk insert plays
 * Add missing FT play to 0021400052
