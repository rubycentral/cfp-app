import React, { Component } from "react"
import PropTypes from "prop-types"
import Alert from './Alert'

class FlashMessages extends Component {
  constructor(props) {
    super(props);
    this.state = {
      messages: props.messages
    }
  }

  render() {
    return(
      <div>
        { this.state.messages.map( message =>
          <Alert key={ message } message={ message } />) }
      </div>
    );
  }
}

FlashMessages.propTypes = {
  messages: PropTypes.array
}

export default FlashMessages
