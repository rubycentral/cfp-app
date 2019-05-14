import React from "react";
import PropTypes from "prop-types";

class BulkCreateModal extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      day: 1,
      rooms: [],
      startTimes: '',
      duration: ''
    }
  }

  render() {
    return (
      <div className='bulk-modal-container'>
        <div className='bulk-modal' onClick={() => {}}>
          <form>
            
          </form>
        </div>
      </div>
    )
  }
}

BulkCreateModal.propTypes = {
  closeBulkTimeSlotModal: PropTypes.func
}

export default BulkCreateModal;