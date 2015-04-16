var Plays = React.createClass({
  getInitialState: function() {
    return {data: {plays: []}};
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
    var plays = this.state.data.plays.map(function (play) {
      return (
        <Play name={play.name} />
      );
    });
    return (
      <div className="container">
      {plays}
      </div>
    );
  }
});

React.render(
  <Plays url={'box_score.json'} />,
  document.getElementById('plays')
);
