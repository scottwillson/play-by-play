'use strict';

let path = require('path');
let baseConfig = require('./base');
let defaultSettings = require('./defaults');

let config = Object.assign({}, baseConfig, {
  entry: ['@babel/polyfill', './src/components/App'],
  cache: false,
  devtool: 'eval-source-map',
  mode: 'development',
  module: defaultSettings.getDefaultModules()
});

config.module.rules.push({
  test: /\.(js|jsx)$/,
  loader: 'babel-loader',
  include: [].concat(
    [ path.join(__dirname, '/../src') ]
  )
});

module.exports = config;
