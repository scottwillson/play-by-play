import React from 'react';
import { render } from 'react-dom'
import { IndexRoute, Router, Route, browserHistory } from 'react-router'
import Games from './Games';
import Game from './Game';

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
      <Route path="games/:game_id/:eventnum" component={Game} />
      <Route path="games/:game_id" component={Game} />
    </Route>
  </Router>
), document.getElementById('app'));