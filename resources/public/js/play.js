var Play = React.createClass({
  render: function() {
    return (
      <div>{this.props.player} ({this.props.team}) {this.props.name}  {this.props.points}</div>
    );
  }
});
