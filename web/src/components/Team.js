import numeral from 'numeral';
import PropTypes from 'prop-types';
import React from 'react';

const Team = props => (
  <tr>
    <td className="mdl-data-table__cell--non-numeric">{props.name}</td>
    <td>{numeral(props.fgs).format('0.0')}</td>
    <td>{numeral(props.fg_attempts).format('0.0')}</td>
    <td>{numeral(props.fg_percentage * 100).format('0.0')}</td>
    <td>{numeral(props.three_point_fgs).format('0.0')}</td>
    <td>{numeral(props.three_point_fg_attempts).format('0.0')}</td>
    <td>{numeral(props.three_point_fg_percentage * 100).format('0.0')}</td>
    <td>{numeral(props.fts).format('0.0')}</td>
    <td>{numeral(props.ft_attempts).format('0.0')}</td>
    <td>{numeral(props.ft_percentage * 100).format('0.0')}</td>
    <td>{numeral(props.assists).format('0.0')}</td>
    <td>{numeral(props.turnovers).format('0.0')}</td>
    <td>{numeral(props.steals).format('0.0')}</td>
    <td>{numeral(props.blocks).format('0.0')}</td>
    <td>{numeral(props.opponent_fgs).format('0.0')}</td>
    <td>{numeral(props.opponent_fg_attempts).format('0.0')}</td>
    <td>{numeral(props.opponent_fg_percentage * 100).format('0.0')}</td>
    <td>{numeral(props.opponent_three_point_fgs).format('0.0')}</td>
    <td>{numeral(props.opponent_three_point_fg_attempts).format('0.0')}</td>
    <td>{numeral(props.opponent_three_point_fg_percentage * 100).format('0.0')}</td>
    <td>{numeral(props.points).format('0.0')}</td>
    <td>{numeral(props.opponent_points).format('0.0')}</td>
    <td>{numeral(props.points_differential).format('0.0')}</td>
  </tr>
);

Team.propTypes = {
  assists: PropTypes.number,
  blocks: PropTypes.number,
  fg_attempts: PropTypes.number,
  fg_percentage: PropTypes.number,
  fgs: PropTypes.number,
  ft_attempts: PropTypes.number,
  ft_percentage: PropTypes.number,
  fts: PropTypes.number,
  name: PropTypes.string,
  opponent_fg_attempts: PropTypes.number,
  opponent_fg_percentage: PropTypes.number,
  opponent_fgs: PropTypes.number,
  opponent_points: PropTypes.number,
  opponent_three_point_fg_attempts: PropTypes.number,
  opponent_three_point_fg_percentage: PropTypes.number,
  opponent_three_point_fgs: PropTypes.number,
  points_differential: PropTypes.number,
  points: PropTypes.number,
  steals: PropTypes.number,
  three_point_fg_attempts: PropTypes.number,
  three_point_fg_percentage: PropTypes.number,
  three_point_fgs: PropTypes.number,
  turnovers: PropTypes.number
 };

export default Team;
