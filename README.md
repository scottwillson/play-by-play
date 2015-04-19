# play-by-play

Stats-based basketball simulation

Excuse to use Clojure + React for something "real"

Use Incanter to validate simulation (t-test, etc.) with real stats

### Install (OS X)
    brew install leiningen

### Run
    lein ring server-headless

Browser: http://0.0.0.0:3000/?date=2012-10-30
Click on Final for box score

    lein run

Run options

  * (default) real world stats
  * box-score: simulate single game
  * day: simulate day of games
  * season: simulate entire season

### Develop
    lein test
    lein test :browser

Browser test requires PhantomJS

### TODO
  * Hot-reload/run for Clojure tests
  * Handle default, no date case
  * Optimize mobile. Type is too small.
  * Use .jsx for JSX files
  * Use param for box score like HOUDEN20121030 (or something)
  * add function for home-points (and probably home-team-name)
  * Grunt/Gulp: https://github.com/newtriks/generator-react-webpack, https://github.com/webpack/grunt-webpack
  * Webpack and friends via Yeoman: npm install -g generator-react-webpack
  * Flux: https://github.com/banderson/generator-flux-react, https://github.com/vn38minhtran/generator-react-flux
  * Browserify: https://github.com/randylien/generator-react-gulp-browserify
  * Karma: Yeoman + http://karma-runner.github.io/0.12/index.html
  * Live reload: https://github.com/webpack/webpack-dev-server, https://github.com/gruntjs/grunt-contrib-connect

## License

Copyright © 2015 Scott Willson

Distributed under the MIT License either version 1.0 or (at
your option) any later version.
