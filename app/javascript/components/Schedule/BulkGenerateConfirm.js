import React from "react";
import PropTypes from "prop-types";

class BulkGenerateConfirm extends React.Component {
  render() {
    const {
      cancelBulkPreview,
      openBulkTimeSlotModal,
      requestBulkTimeSlotCreate
    } = this.props;

    return (
      <div className='generate-confirm'>
        <button onClick={cancelBulkPreview}>Cancel</button>
        <button onClick={openBulkTimeSlotModal}>Edit</button>
        <button onClick={requestBulkTimeSlotCreate}>Confirm</button>
      </div>
    )
  }
}

BulkGenerateConfirm.propTypes = {
  cancelBulkPreview: PropTypes.func,
  openBulkTimeSlotModal: PropTypes.func,
  requestBulkTimeSlotCreate: PropTypes.func
}

export default BulkGenerateConfirm;
