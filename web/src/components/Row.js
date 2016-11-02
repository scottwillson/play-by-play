import React from 'react';

const Row = props => (
  <tr>
    <td id={props.data.eventnum}>
      <a href={`http://stats.nba.com/game/#!/00${props.data.nba_id}/playbyplay/#play${props.data.eventnum}`}>{props.data.eventnum}</a>
    </td>
    <td>{props.data.period}</td>
    <td>{props.data.pctimestring}</td>
    <td>{props.data.eventmsgtype}</td>
    <td>{props.data.eventmsgactiontype}</td>
    <td className="mdl-data-table__cell--non-numeric">{props.data.visitordescription}</td>
    <td className="mdl-data-table__cell--non-numeric">{props.data.homedescription}</td>
    <td>{props.data.person1type}</td>
    <td>{props.data.person2type}</td>
    <td>{props.data.person3type}</td>
    <td>{props.data.player1_id}</td>
    <td className="mdl-data-table__cell--non-numeric">{props.data.player1_name}</td>
    <td className="mdl-data-table__cell--non-numeric">{props.data.player1_team_abbreviation}</td>
    <td className="mdl-data-table__cell--non-numeric">{props.data.player1_team_city}</td>
    <td>{props.data.player1_team_id}</td>
    <td className="mdl-data-table__cell--non-numeric">{props.data.player1_team_nickname}</td>
    <td>{props.data.player2_id}</td>
    <td className="mdl-data-table__cell--non-numeric">{props.data.player2_name}</td>
    <td className="mdl-data-table__cell--non-numeric">{props.data.player2_team_abbreviation}</td>
    <td className="mdl-data-table__cell--non-numeric">{props.data.player2_team_city}</td>
    <td>{props.data.player2_team_id}</td>
    <td className="mdl-data-table__cell--non-numeric">{props.data.player2_team_nickname}</td>
    <td>{props.data.player3_id}</td>
    <td className="mdl-data-table__cell--non-numeric">{props.data.player3_name}</td>
    <td className="mdl-data-table__cell--non-numeric">{props.data.player3_team_abbreviation}</td>
    <td className="mdl-data-table__cell--non-numeric">{props.data.player3_team_city}</td>
    <td>{props.data.player3_team_id}</td>
    <td className="mdl-data-table__cell--non-numeric">{props.data.player3_team_nickname}</td>
    <td>{props.data.score}</td>
    <td>{props.data.scoremargin}</td>
    <td>{props.data.wctimestring}</td>
    <td className="mdl-data-table__cell--non-numeric">{props.data.neutraldescription}</td>
  </tr>
);

export default Row;
