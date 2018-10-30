import * as R from 'ramda';
import React from 'react';
import request from 'superagent';
import Team from './Team';

class Teams extends React.Component {
  constructor(props) {
    super(props);
    this.state = props;
  }

  render() {
    return (
      <div>
        <div className="mdl-grid">
          <div className="mdl-cell mdl-cell--12-col">
            <table className="mdl-data-table mdl-js-data-table mdl-shadow--2dp">
              <thead>
                <tr>
                  <th className="mdl-data-table__cell--non-numeric">Name</th>
                  <th>FGM</th>
                  <th>FGA</th>
                  <th>FG%</th>
                  <th>3FGM</th>
                  <th>3FGA</th>
                  <th>3FG%</th>
                  <th>FT</th>
                  <th>FTA</th>
                  <th>FT%</th>
                  <th>AST</th>
                  <th>TO</th>
                  <th>STL</th>
                  <th>BLK</th>
                  <th>OPP FGM</th>
                  <th>OPP FGA</th>
                  <th>OPP FG%</th>
                  <th>OPP 3FGM</th>
                  <th>OPP 3FGA</th>
                  <th>OPP 3FG%</th>
                  <th>Points</th>
                  <th>OPP Points</th>
                  <th>+/-</th>
                </tr>
              </thead>
              <tbody>
                {R.sortBy(R.prop('name'), this.state.teams).map(team => <Team key={team.id} {...team} />)}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    );
  }

  componentWillMount() {
    request
      .get('/teams.json')
      .accept('json')
      .end(function(err, res) {
        if (err) {
          document.querySelector('.mdl-js-snackbar').MaterialSnackbar.showSnackbar({
            message: err.message,
            timeout: 5000
          });
        }
        else {
          this.setState({teams: res.body});
        }
      }.bind(this));
  }
}

Teams.defaultProps = {
  teams: []
};

export default Teams;
