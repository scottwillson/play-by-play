var Player = React.createClass({
  render: function() {
    return (
      <tr className="player">
        <td className="name">{this.props.name}</td>
        <td className="points">{this.props.points}</td>
      </tr>
    );
  }
});
