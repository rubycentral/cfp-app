import React from "react";
import PropTypes from "prop-types";

class BulkGenerateConfirm extends React.Component {
  render() {
    const {
      cancelBulkPreview,
      openBulkTimeSlotModal,
      bulkTimeSlotModalEditState
    } = this.props;

    return (
      <div className='generate-confirm'>
        <button onClick={cancelBulkPreview}>Cancel</button>
        <button onClick={openBulkTimeSlotModal}>Edit</button>
        <button>Confirm</button>
      </div>
    )
  }
}

BulkGenerateConfirm.propTypes = {
  cancelBulkPreview: PropTypes.func,
  openBulkTimeSlotModal: PropTypes.func,
  bulkTimeSlotModalEditState: PropTypes.object
}

export default BulkGenerateConfirm;
