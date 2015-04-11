var BoxScore = React.createClass({
  getInitialState: function() {
    return {
      teams: [{
          name: "Washington Wizards",
          location: "visitor",
          points: 97,
          players: [{
            name: "Kevin Durant",
            points: 17
          }]
        }, {
          name: "Cleveland Cavaliers",
          location: "home",
          points: 99,
          players: [{
            name: "Mo Williams",
            points: 17
          }]
        }]};
      },

  render: function() {
    var boxScore = this.state.teams.map(function (team) {
      return (
        <Team name={team.name} players={team.players} location={team.location} points={team.points}/>
      );
    });
    return (
      <div className="container">
      {boxScore}
      </div>
    );
  }
});

React.render(
  <BoxScore />,
  document.getElementById('box-score')
);
