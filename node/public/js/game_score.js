var GameScore = React.createClass({
  render: function() {
    return (
      <div className="game-score">
        <h2 className="team-name">
          {this.props.team}
        </h2>
        {this.props.score}
      </div>
    );
  }
});
