import React, { Component, Fragment } from "react"
import PropTypes from "prop-types"

class Alert extends Component {
  formatedMessages = messages => {
    let message = ''

    messages.forEach(msg => {
      message += `${msg}. `
    })

    return message
  }

  render() {
    const messages = this.props.messages;

    return (
      <div className="scheduling-error alert alert-danger">
        <button className='close' onClick={this.props.onClose}> &times; </button>
        { this.formatedMessages(messages) }
      </div>
    )
  }
}

Alert.propTypes = {
  onClose: PropTypes.func,
  messages: PropTypes.array,
}

export default Alert
