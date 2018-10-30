'use strict';
let path = require('path');
let defaultSettings = require('./defaults');

// Additional npm or bower modules to include in builds
// Add all foreign plugins you may need into this array
// @example:
// let npmBase = path.join(__dirname, '../node_modules');

module.exports = {
  devtool: 'eval',
  output: {
    path: path.join(__dirname, '/../dist/assets'),
    filename: 'app.js',
    publicPath: `.${defaultSettings.publicPath}`
  },
  devServer: {
    contentBase: './src/',
    historyApiFallback: true,
    hot: true,
    port: defaultSettings.port,
    publicPath: defaultSettings.publicPath,
    noInfo: false,
    stats: 'errors-only'
  },
  resolve: {
    extensions: ['.js', '.jsx'],
    alias: {
      components: `${defaultSettings.srcPath}/components/`,
      styles: `${defaultSettings.srcPath}/styles/`,
      config: `${defaultSettings.srcPath}/config/` + process.env.REACT_WEBPACK_ENV
    }
  },
  module: {}
};
