import React from "react"
import PropTypes from "prop-types"

class Session extends React.Component {
  constructor(props) {
    super(props);

    this.state = {

    }
  }

  render() {
    const {sessionStart, sessionEnd} = this.props;

    return(
      <div className='timeSlot'></div>
    )
  }
}