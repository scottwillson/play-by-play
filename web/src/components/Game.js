import PropTypes from 'prop-types';
import React from 'react';
import request from 'superagent';
import Row from './Row';

class Game extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      eventnum: props.match.params.eventnum,
      nba_id: props.match.params.nba_id,
      rows: []
    };
  }

  render() {
    return (
      <table className="mdl-data-table mdl-js-data-table mdl-shadow--2dp">
        <thead>
          <tr>
            <th className="eventnum">eventnum</th>
            <th>period</th>
            <th>pctimestring</th>
            <th>eventmsgtype</th>
            <th>eventmsgactiontype</th>
            <th className="mdl-data-table__cell--non-numeric">visitordescription</th>
            <th className="mdl-data-table__cell--non-numeric">homedescription</th>
            <th>person1type</th>
            <th>person2type</th>
            <th>person3type</th>
            <th>player1_id</th>
            <th className="mdl-data-table__cell--non-numeric">player1_name</th>
            <th className="mdl-data-table__cell--non-numeric">player1_team_abbreviation</th>
            <th className="mdl-data-table__cell--non-numeric">player1_team_city</th>
            <th>player1_team_id</th>
            <th className="mdl-data-table__cell--non-numeric">player1_team_nickname</th>
            <th>player2_id</th>
            <th className="mdl-data-table__cell--non-numeric">player2_name</th>
            <th className="mdl-data-table__cell--non-numeric">player2_team_abbreviation</th>
            <th className="mdl-data-table__cell--non-numeric">player2_team_city</th>
            <th>player2_team_id</th>
            <th className="mdl-data-table__cell--non-numeric">player2_team_nickname</th>
            <th>player3_id</th>
            <th className="mdl-data-table__cell--non-numeric">player3_name</th>
            <th className="mdl-data-table__cell--non-numeric">player3_team_abbreviation</th>
            <th className="mdl-data-table__cell--non-numeric">player3_team_city</th>
            <th>player3_team_id</th>
            <th className="mdl-data-table__cell--non-numeric">player3_team_nickname</th>
            <th>score</th>
            <th>scoremargin</th>
            <th>wctimestring</th>
            <th className="mdl-data-table__cell--non-numeric">neutraldescription</th>
          </tr>
        </thead>
        <tbody>
          {this.state.rows.map(function(row) {
            return <Row key={row.id} data={row} />;
          })}
        </tbody>
      </table>
    )
  }

  componentWillMount() {
    request
      .get(`/games/${this.state.nba_id}.json`)
      .accept('json')
      .end(function(err, res) {
        if (err) {
          document.querySelector('.mdl-js-snackbar').MaterialSnackbar.showSnackbar({
            message: err.message,
            timeout: 5000
          });
        }
        else {
          this.setState({rows: res.body});
        }
      }.bind(this));
  }

  componentDidUpdate() {
    if (this.state.eventnum) {
      document.getElementById(this.state.eventnum).scrollIntoView(true);
    }
  }
}

Game.contextTypes = { router: PropTypes.object.isRequired };

Game.propTypes = { match: PropTypes.object };

export default Game;
