var BoxScore = React.createClass({
  getInitialState: function() {
    return {data: {teams: []}};
  },

  // TODO DRY up dupe code
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
    var boxScore = this.state.data.teams.map(function (team) {
      return (
        <Team name={team.name} players={team.players} location={team.location} points={team.points}/>
      );
    });
    return (
      <div className="col-md-12">
      <h2>Box Score</h2>
      {boxScore}
      </div>
    );
  }
});

React.render(
  <BoxScore url={'box_score.json'} />,
  document.getElementById('box-score')
);
