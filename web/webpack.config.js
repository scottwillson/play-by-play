'use strict';

const path = require('path');
const args = require('minimist')(process.argv.slice(2));

const allowedEnvs = ['dev', 'dist', 'test'];

function envFromArgs(args) {
  if (args._.length > 0 && args._.indexOf('start') !== -1) {
    return 'test';
  } else if (args.env) {
    return args.env;
  }
  return 'dev';
}

const env = envFromArgs(args);
process.env.REACT_WEBPACK_ENV = env;

function buildConfig(wantedEnv) {
  if (!wantedEnv || allowedEnvs.indexOf(wantedEnv) == -1) {
    throw `'${wantedEnv}' not in ${allowedEnvs}`;
  }

  return require(path.join(__dirname, `webpack.config/${wantedEnv}`));
}

module.exports = buildConfig(env);
