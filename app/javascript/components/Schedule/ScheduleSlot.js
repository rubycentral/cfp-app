import React from "react";
import PropTypes from "prop-types";

import ProgramSession from './ProgramSession';
import { patchTimeSlot } from "../../apiCalls";

class ScheduleSlot extends React.Component {
  
  onDragOver = e => {
    e.preventDefault();
  };

  onDrop = slot => {
    const session = this.props.draggedSession;
    const { csrf } = this.props;

    patchTimeSlot(slot, session, csrf);

    this.props.changeDragged(null);
  };

  render() {
    const { slot, ripTime, startTime, sessions } = this.props;

    const slotStartTime = ripTime(slot.start_time);
    const slotEndTime = ripTime(slot.end_time);

    const style = {
      top: (slotStartTime - startTime) * 90 + "px",
      height: (slotEndTime - slotStartTime) * 90 + "px"
    };

    let session = <React.Fragment/>
    if (slot.program_session_id) {
      let matchedSession = sessions.find(
        session => session.id === slot.program_session_id
      )
      session = <ProgramSession session={matchedSession} />
    }

    return (
      <div
        className="schedule_slot"
        style={style}
        key={slot.id}
        onDragOver={e => this.onDragOver(e)}
        onDrop={() => this.onDrop(slot)}
      >
        {session}
      </div>
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