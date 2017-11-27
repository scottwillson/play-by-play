import "babel-polyfill";
import React from 'react';
import { render } from 'react-dom'
import { BrowserRouter, Route, Switch } from 'react-router-dom';
import Game from './Game';
import Games from './Games';
import Teams from './Teams';

require('styles/app.css');

render((
  <BrowserRouter>
    <Switch>
      <Route exact path="/" component={Games} />
      <Route path="/games/:nba_id/:eventnum" component={Game} />
      <Route path="/games/:nba_id" component={Game} />
      <Route path="/teams" component={Teams} />
    </Switch>
  </BrowserRouter>
), document.getElementById('app'))
