import React from 'react';
import { render } from 'react-dom'
import { IndexRoute, Router, Route, browserHistory } from 'react-router'
import Games from './Games';
import Game from './Game';
import Teams from './Teams';

require('styles/app.css');

class App extends React.Component {
  render() {
    return this.props.children;
  }
}

render((
  <Router history={browserHistory}>
    <Route path="/" component={App}>
      <IndexRoute component={Games} />
      <Route path="games/:nba_id/:eventnum" component={Game} />
      <Route path="games/:nba_id" component={Game} />
      <Route path="teams" component={Teams} />
    </Route>
  </Router>
), document.getElementById('app'));
