var TeamGameScore = React.createClass({
  render: function() {
    return (
      <tr className={this.props.location}>
        <td className="team-name">{this.props.name}</td>
        <td className="points">{this.props.points}</td>
      </tr>
    );
  }
});
