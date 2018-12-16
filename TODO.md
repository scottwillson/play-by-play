* Check for unused requires
* players
  * store players in repository
  * make play distributions by player
  * replace random player with distribution sample
  * shot becomes part of play key?
  * remove assisted? and just use assist ?
  * consolidate game.visitor.players.index { |player| player.nba_id == player1_id } in Row
* `fouled` should be optional for technical_fouls
* Replace game.home and game.visitor with game.team(:home|visitor) where it makes sense
* Investigate weak correlation between team strength and wins (GSW should win more and NYK less than either do in simulation)
 * bad FGs counts: fixed, need tests
 * OPP FGs FG% is OK
 * GSW should probably win at home against NYK 95-99% but is more like 83%
   (accounting for location was worth about 13%)
 * GSW should probably win against MIL (.500 team) ~70% but is more like 63%
 * Removing defense events seems to slightly increase good team strength, but not much
 * 3PA seem low and too regular. Should be 14.9-32.7, but is 17.2-26.2. % looks correct, though
 * rebounds are high, esp. offensive rebounds
 * turnovers are low
 * PFs a little low
 * Points are too averaged
* do imports concurrently
* Test season simulation with database
* Change Simulation::Game.play! signature to use keyed arguments
* share repository?
* Use better Rspec predicate matchers
* Refactor season simulation to be more like Redux
* Add sequence number to row? (or just rely on ID)
* better favicon
* change model initialize to star-attribute?
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
* add bin/setup
* test rake tasks
* add logging
* optimize play count query with a single pre-calculated key column
* cache play count query (if not already)
* remove dupe webpacking
* remove possessions home_id and visitor_id?
* add progress animation to teams page
* Only apply other team's probabilities when they can affect outcome. E.g., other team should no affect FT%.
* Collapse duplicate PlayProbabilityDistributions?
* show team year stats by year
* save simulation results
* Consider allowing game#day_id and day#season_id to be null to simplify testing (and change season import to backfill update these)
* DB FKs?
* Refactor PlayProbabilityDistribution, especially `#for`
* sort team stats table
* Break out persistent tests
* Add persistent game spec factory method
* add default for Day and maybe Season to allow just calling .new
* add default for source(s)
* play should be required to add possession
* each Season should have a League?
* Repository.league should be leagues?
* possessions table should have position field for ordering and repository should read possessions in order
* ES6
* Update "babel-preset-env now: please read babeljs.io/env"
* Make seconds generator (source?) a dependency for play generator?
* Move "Game not over" check to Game or GamePlay? Need an add possession method.
* Replace code like self.possession = attributes.delete(:possession) with whitelisted attributes
* Better solution than `game.add_play play, play_generator.row`?
* replace Play#team with Play#player
* ensure database: true if spec uses real repository
* ensure database: false makes a mock repository
* change FTs from list of teams to list of players
* play player validation
* 6 PFs -> ejection
* 2 techs -> ejection
* fouled player must be one shooting
* player must be in game
* assist and shot must be different
* jump and tip must be different
* How to account for assist influence when players are on/off court?
* How do players influence teammates?
* How do players influence opponents?
* Draft:
  * player sample previous year * 4
  * player sample (year - 2) * 2
  * player sample (year - 3)
  * player as teammate for each teammate * 0.2
  * opponent previous year
  * opponent (year - 2) * 0.5
  * opponent (year - 3) * 0.25
  * regress towards mean based on minutes (if player averages 5 minutes a game and is now playing 30 minutes, weight average of players who play 5 min/game)
  * adjust for fatigue (more than 30 minutes)
  * adjust for warmup (less than ~5 minutes)
* Decompose Sample#Row
* Mock::Repository inherit from real Repository?
* Pass in mock DB instead?
* is mock repository useful?
* Ditch Model?
* Ensure sample play players are correct
* player-team associations need to be more varied (rosters vary by day/year/game)
* Rename to BallDontLie
