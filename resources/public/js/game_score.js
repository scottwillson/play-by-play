var GameScore = React.createClass({
  render: function() {
    var teamGameScores = this.props.teams.map(function (team) {
      return (
        <TeamGameScore name={team.name} points={team.points} location={team.location} />
      );
    });
    return (
        <div className="col-md-4">
          <table className="table game-score">
            <thead>
              <tr>
                <th><a href ="/box_score.html">Final</a></th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {teamGameScores}
            </tbody>
          </table>
        </div>
    );
  }
});
