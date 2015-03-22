var data = [
  {team: "Orlando", score: "101"},
  {team: "New Jersey", score: "98"}
];

var GameScores = React.createClass({
  render: function() {
    var gameScores = this.props.data.map(function (gameScore) {
      return (
        <GameScore team={gameScore.team}>
          {gameScore.score}
        </GameScore>
      );
    });
    return (
      <div className="game-scores">
        {gameScores}
      </div>
    );
  }
});


React.render(
  <GameScores data={data} />,
  document.getElementById('game-scores')
);
