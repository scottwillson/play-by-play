Play by Play
============
Ruby basketball simulation. Partial recreation of a BASIC college basketball simulation I wrote in the 1980s. Inspired by discussion about [The Hot Hand in Basketball: On the Misperception of Random Sequences](http://bit.ly/1PkU2Qh): "Kobe Bryant shooting a basketball is essentially flipping a coin." Given seasons of NBA data, I can model those coin flips.

The project reads [NBA play-by-play game files](/) and builds a probability distribution. It uses the probability distribution and a model to simulate games. There is also a web app to browse imported data.

Game simulation is very simple. There is a "home" team and a "visitor" team, each with exactly equal chances, league-average to make field goals, block shots, etc. There isn't even the concept of players, yet! Even this simulation is interesting: given two perfectly-matched teams, ~10% of games are 20-point blowouts. Maybe there's [more than coin-flipping](http://www.sloansportsconference.com/?p=11265) going on? An entire simulated season routinely produces at least one 50-win team and one 33-win team.

Install
=======
 * On OS X, just run bin/setup
 * [Install Ruby](https://www.ruby-lang.org/en/documentation/installation/), [node.js](https://nodejs.org/en/download/)
 * `gem install bundler`
 * `bundle`
 * `cd web; npm install; npm run dist:dev`

Test
====
 * [Install phantomjs](http://phantomjs.org/download.html)
`rspec`

Simulate a single game
======================
`rake`

This Rake task also populates the probability distribution from three sample games in spec/data.

Development
===========
`rake spec:fast` runs all specs, skipping any that rely on the database or web server

`rake import:game` imports a single game. Use `rake parse:game` to check parsing logic without saving the results.

See the Rakefile for options and other Rake tasks.

`rackup` to run the web app and browse http://localhost:9292/ to view import errors.

Tech stack
==========
Ruby 2.4 with minimal gems
[Sinatra](http://www.sinatrarb.com/) for web API
[React](https://facebook.github.io/react/) for frontend web UI

Model
=====
The model and simulation borrows concepts from [finite-state machines](https://en.wikipedia.org/wiki/Finite-state_machine), [Markov chains](https://en.wikipedia.org/wiki/Markov_chain), Redux and [Monte Carlo](https://en.wikipedia.org/wiki/Monte_Carlo_method) simulations.

Games are modeled as state machines. State is described by a small number of attributes (is the ball in play?, which team has the ball?, what period is it?, are free throws pending?). Each state has a set number of valid transitions to other states. Each transition also has a probability.

Taken together, a game is a chain of game states. This is, more or less, a Markov model and a Markov chain. See Markov below.

Terminology
-----------
Each game state is a Ruby [Possession](lib/play_by_play/model/possession.rb) class. Each transition between Possessions is a [Play](lib/play_by_play/model/play.rb). A [Simulation::Game](lib/play_by_play/simulation/game.rb) is a chain of Possessions.

A Game is a store of immutable Possessions and Plays. Each Play is a state transition that produces a new Possession. A new Possession can only be created by a Play.

In state machines, plays could also be considered actions or events. "Possession" is  nebulous in common usage. Here, it could also have been called a "game" or "game state".

The probability distribution is the probability that a transition (Play) will occur given a game state (Possession). It could also be called a transition matrix or a conditional probability distribution.

Only some transitions are valid from certain states. For example, steals can never occur when free throes are pending. All states are valid from each other. They are all "accessible" Markov states.

In some places, it is easier to express plays and possessions with symbols. For example: { ball_in_play: true, team: :home } => [ :turnover ] => { ball_in_play: true, team: :visitor }

Redux
-----
While not strictly a Redux app, the simulation uses the reducer, state, and action ideas from [Redux](http://redux.js.org/docs/basics/Reducers.html). Possessions are immutable Redux states, Plays are actions, and the [GamePlay](lib/play_by_play/model/game_play.rb) play! method is a reducer. GamePlay.play!(possession, play) => possession is equivalent to Redux's function(previousState, action) => newState.

A Play is a record of an "applied" action, either from a real-world sample or a simulation. The Play key (:rebound, team: :defense) is the Redux action.

This is a handy way to model basketball games that leads to concise, testable model code.

System
------
The larger system accepts play-by-play JSON files as input and outputs Simulation::Game.
Input: historical state transitions. Output: chain of states

Modules:
 * Sample. Import JSON files from real world games.
 * Model. Abstract model of basketball game.
 * Simulation. Use probabilities from Sample to run Model to simulation a game or season of games.
 * View. Display Simulation output as text.
 * Web. Web UI.

Many modules have duplicate names (Game, Team), but these duplicates are different, though related concepts. Mixing those concepts makes for confusing code.

States
------
Possessions are game states at a point in time. Game state can be considered essentially infinite. Every combination of players, time remaining, score, fouls, etc. can produce different transition probabilities.

However, to model what is _possible_ is much more finite. The model uses just:
 * ball in play?
 * team has possession?
 * pending free throws?
 * pending technical free throws?

Taken in order, the states are exclusive, so game state can be reduced in [PlayMatrix](lib/play_by_play/model/play_matrix.rb) to just: technical free throws?, free throws?, team?, ball in play?, any time remaining?.

Games could be modeled as several concurrent game state machines. One each for possession, FTs, etc., but that isn't helpful in practice.

Simulation
----------
The simulation is inspired by the Monte Carlo method, but isn't really a Monte Carlo simulation. It could be considered a Monte Carlo generator run once. (And could be run multiple times to be a true Monte Carlo simulation).

The RandomPlayGenerator is a "roulette wheel". The model determines which slots (plays) are on the wheel. Historical sample data determines the width of those slots. Similar to [log5](https://web.archive.org/web/20140123014747/http://www.chancesis.com/2010/10/03/the-origins-of-log5).

Markov
------
Markov models and chains help build a game model, but they are tools for predicting the probability of future states, not for simulations. This simulation care about the *type* of transition for counting stats like points, field goals made, assists, and more.

Our model also has multiple transitions from two states. Typical Markov examples only have one transition between two states, because only the probability matters. Matrices also aren't very useful here, though there are good applications for [baseball strategy](http://www.pankin.com/markov/theory.htm).

Old game
========
The old BASIC game had a text box score and a scrolling play-by-log. Similar to what you might hear on the radio or view on [nba.com](http://stats.nba.com/game/#!/20160108/playbyplay/#qtr1). "Coaches" playing the game could sub players in and out, assign position, defensive assignments, and choose basic strategy (offense, defense, rebound, steals, set picks, pass).

First steps on the new simulation are to build a solid game model and feed it good data. With that in place, it should be possible to make a playable simulation.
