import numeral from 'numeral';
import React from 'react';

const Team = props => (
  <tr>
    <td className="mdl-data-table__cell--non-numeric">{props.name}</td>
    <td>{numeral(props.fgs).format('0.0')}</td>
    <td>{numeral(props.fg_attempts).format('0.0')}</td>
    <td>{numeral(props.fg_percentage * 100).format('0.0')}</td>
    <td>{numeral(props.points).format('0.0')}</td>
  </tr>
);

export default Team;
