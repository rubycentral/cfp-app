import React, { Component } from "react"
import PropTypes from "prop-types"

class TimeSlotModal extends Component {
  constructor(props) {
    super(props)
    this.state = {

    }
  }

  componentDidMount() {
    if ( this.props.programSession ) {
      console.log('TEST')
    }
  }

  render() {
    return (
      <div className='modal-container'>
        <div className='bulk-modal'>
          
        </div>
      </div>
    )
  }
}

TimeSlotModal.propTypes = {

}

export default TimeSlotModal
