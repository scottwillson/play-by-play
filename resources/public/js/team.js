var Team = React.createClass({
  render: function() {
    var players = this.props.players.map(function (player) {
      return (
        <Player name={player.name} points={player.points}/>
      );
    });

    return (
      <div className="col-md-12 {this.props.location}">
        <h2 className="team-name">{this.props.name}</h2>
        <table className="table box-score">
          <thead>
          <tr>
            <th className="name">Player</th>
            <th className="points">Points</th>
          </tr>
          </thead>
          <tbody>
            {players}
            <tr className="totals">
              <td></td>
              <td className="points">{this.props.points}</td>
            </tr>
          </tbody>
        </table>
      </div>
    );
  }
});
