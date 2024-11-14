import React, { Component } from 'react';
import PropTypes from 'prop-types';

class BulkGenerateConfirm extends Component {
  render() {
    const { cancelBulkPreview, openBulkTimeSlotModal, requestBulkTimeSlotCreate } = this.props;

    return (
      <div className="generate-confirm">
        <span>Previewing Grid changes</span>
        <div className="button-container">
          <button className="btn" onClick={cancelBulkPreview}>
            Cancel
          </button>
          <button className="btn" onClick={openBulkTimeSlotModal}>
            Edit
          </button>
          <button className="btn" onClick={requestBulkTimeSlotCreate}>
            Save
          </button>
        </div>
      </div>
    );
  }
}

BulkGenerateConfirm.propTypes = {
  cancelBulkPreview: PropTypes.func,
  openBulkTimeSlotModal: PropTypes.func,
  requestBulkTimeSlotCreate: PropTypes.func,
};

export { BulkGenerateConfirm };
