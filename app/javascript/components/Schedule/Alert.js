import React, { Component, Fragment } from 'react';
import PropTypes from 'prop-types';

class Alert extends Component {
  render() {
    const messages = this.props.messages;

    return (
      <div className="scheduling-error alert alert-danger">
        <button className="close" onClick={this.props.onClose}>
          {' '}
          &times;{' '}
        </button>
        {messages.map((message) => {
          return <p>{message}</p>;
        })}
      </div>
    );
  }
}

Alert.propTypes = {
  onClose: PropTypes.func,
  messages: PropTypes.array,
};

export { Alert };
