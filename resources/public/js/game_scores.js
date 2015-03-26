var GameScores = React.createClass({
  getInitialState: function() {
    return {data: []};
  },

  componentDidMount: function() {
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      success: function(data) {
        this.setState({data: data});
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },

  render: function() {
    var gameScores = this.state.data.map(function (gameScore) {
      return (
        <GameScore homeTeam={gameScore.homeTeam}
                   visitorTeam={gameScore.visitorTeam}
                   homeScore={gameScore.homeScore}
                   visitorScore={gameScore.visitorScore}>
          {gameScore.score}
        </GameScore>

      );
    });
    return (
      <div className="container">
        <h1>March 10, 2015</h1>
        {gameScores}
      </div>
    );
  }
});

React.render(
  <GameScores url={'index.json?date=2014-01-01'} />,
  document.getElementById('game-scores')
);
