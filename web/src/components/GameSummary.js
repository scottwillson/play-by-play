import PropTypes from 'prop-types';
import React from 'react';
import { Link } from 'react-router-dom'

class GameSummary extends React.Component {
  render() {
    return (
      <tr key={this.props.file.id}>
        <td>
          <Link to={`/games/${this.props.file.nba_id}`}>{this.props.file.nba_id}</Link>
        </td>
        <td className="mdl-data-table__cell--non-numeric">{this.props.file.visitor_team_name}</td>
        <td className="mdl-data-table__cell--non-numeric">{this.props.file.home_team_name}</td>
        <td>
          <Link to={`/games/${this.props.file.nba_id}/${this.props.file.error_eventnum}`}>{this.props.file.error_eventnum}</Link>
        </td>
        <td className="mdl-data-table__cell--non-numeric">{this.props.file.errors}</td>
      </tr>
    )
  }
}

GameSummary.contextTypes = { router: PropTypes.object.isRequired };
GameSummary.propTypes = { file: PropTypes.object };

export default GameSummary;
