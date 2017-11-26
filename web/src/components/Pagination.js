import PropTypes from 'prop-types';
import React from 'react';

class Pagination extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      page: props.page,
      pageChangeListener: props.pageChangeListener
    };
    this.nextPage = this.nextPage.bind(this);
    this.previousPage = this.previousPage.bind(this);
  }

  nextPage() {
    this.setState({page: this.state.page + 1});
    this.state.pageChangeListener.pagedChanged(this.state.page + 1);
  }

  previousPage() {
    this.setState({page: this.state.page - 1});
    this.state.pageChangeListener.pagedChanged(this.state.page - 1);
  }

  render() {
    return (
      <div className="mdl-grid">
        <div className="mdl-cell mdl-cell--2-col">
          <button className="mdl-button mdl-js-button mdl-button--fab mdl-button--mini-fab mdl-button--colored mdl-js-ripple-effect"
            onClick={this.previousPage}>
            <i className="material-icons">arrow_back</i>
          </button>
          <button className="mdl-button mdl-js-button mdl-button--fab mdl-button--mini-fab mdl-button--colored mdl-js-ripple-effect"
            onClick={this.nextPage}>
            <i className="material-icons">arrow_forward</i>
          </button>
        </div>
      </div>
    )
  }
}

Pagination.propTypes = { page: PropTypes.number };
Pagination.defaultProps = { page: 1 };

export default Pagination;
