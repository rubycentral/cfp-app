import React from "react";
import PropTypes from "prop-types";

import { patchTimeSlot } from "../../apiCalls";

class ScheduleSlot extends React.Component {
  
  onDragOver = e => {
    e.preventDefault();
  };

  onDrop = slot => {
    const session = this.props.draggedSession;

    patchTimeSlot(slot, session);

    this.props.changeDragged(null);
  };

  render() {
    const { slot, ripTime, startTime } = this.props;

    const slotStartTime = ripTime(slot.start_time);
    const slotEndTime = ripTime(slot.end_time);

    const style = {
      top: (slotStartTime - startTime) * 90 + "px",
      height: (slotEndTime - slotStartTime) * 90 + "px"
    };
    
    return (
      <div
        className="schedule_slot"
        style={style}
        key={slot.id}
        onDragOver={e => this.onDragOver(e)}
        onDrop={() => this.onDrop(slot)}
      />
    );
  }
}

ScheduleSlot.propTypes = {
  slot: PropTypes.object,
  ripTime: PropTypes.func,
  startTime: PropTypes.number,
  changeDragged: PropTypes.func,
  draggedSession: PropTypes.object
}

export default ScheduleSlot