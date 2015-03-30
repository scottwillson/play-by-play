var GameScore = React.createClass({
  render: function() {
    return (
        <div className="col-md-4">
          <table className="table game-score">
            <thead>
              <tr>
                <th>Final</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <tr className="visitor">
                <td className="team-name">{this.props.visitorTeam}</td>
                <td className="score">{this.props.visitorScore}</td>
              </tr>
              <tr className="home">
                <td className="team-name">{this.props.homeTeam}</td>
                <td className="score">{this.props.homeScore}</td>
              </tr>
            </tbody>
          </table>
        </div>
    );
  }
});
