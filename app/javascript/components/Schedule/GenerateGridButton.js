import React from "react";
import PropTypes from "prop-types";

class GenerateGridButton extends React.Component {
  render() {
    const { openBulkTimeSlotModal } = this.props;

    return (
      <button className='generate_btn btn btn-primary'
        onClick={openBulkTimeSlotModal}
      >Generate Grid</button>
    )
  }
}

GenerateGridButton.propTypes = {
  dayViewing: PropTypes.number,
  generateGridPath: PropTypes.string
}

export default GenerateGridButton;