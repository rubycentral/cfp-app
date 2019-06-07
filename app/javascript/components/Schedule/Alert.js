import React, { Component, Fragment } from "react"
import PropTypes from "prop-types"

class Alert extends Component {
  render() {
    const message = this.props.message;

    return (
      <div className="scheduling-error alert alert-danger">
        <button className='close' data-dismiss='alert'> &times; </button>
        { message }
      </div>
    )
  }
}

Alert.propTypes = {
  message: PropTypes.string
}

export default Alert
