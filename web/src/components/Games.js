import PropTypes from 'prop-types';
import request from 'superagent';
import React from 'react';
import GameSummary from './GameSummary';
import Pagination from './Pagination';

class Games extends React.Component {
  constructor(props) {
    super(props);
    this.state = { playByPlayFiles: [] };
  }

  render() {
    return (
      <div>
        <div className="mdl-grid">
          <div className="mdl-cell mdl-cell--12-col">
            <table className="mdl-data-table mdl-js-data-table mdl-shadow--2dp">
              <thead>
                <tr>
                  <th>Game ID</th>
                  <th className="mdl-data-table__cell--non-numeric">Visitor</th>
                  <th className="mdl-data-table__cell--non-numeric">Home</th>
                  <th>Error Event #</th>
                  <th className="mdl-data-table__cell--non-numeric">Error</th>
                </tr>
              </thead>
              <tbody>
                {this.state.playByPlayFiles.map(file => <GameSummary key={file.id} file={file}/>) }
              </tbody>
            </table>
          </div>
        </div>
        <Pagination pageChangeListener={this} />
      </div>
    );
  }

  pagedChanged(page) {
    this.fetchData(page);
  }

  componentWillMount() {
    this.fetchData();
  }

  fetchData(page) {
    request
      .get('/games.json')
      .query(this.fetchDataQuery(page))
      .accept('json')
      .end(function(err, res) {
        if (err) {
          document.querySelector('.mdl-js-snackbar').MaterialSnackbar.showSnackbar({
            message: err.message,
            timeout: 5000
          });
        }
        else {
          this.setState({
            playByPlayFiles: res.body
          })
        }
      }.bind(this));
  }

  fetchDataQuery(page) {
    if (page) {
      return { page: page };
    }
    else {
      return {};
    }
  }
}

Games.contextTypes = { router: PropTypes.object.isRequired };

export default Games;
