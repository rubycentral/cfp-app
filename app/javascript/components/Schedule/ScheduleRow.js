import React from "react";
import PropTypes from "prop-types"

import { patchTimeSlot } from "../../apiCalls";

import ScheduleSlot from './ScheduleSlot';

class ScheduleRow extends React.Component {
  render() {
    const {
      height,
      room,
      startTime,
      ripTime,
      schedule,
      dayViewing,
      draggedSession,
      changeDragged,
      csrf,
      sessions
    } = this.props;

    const roomID = room.id;
    const thisRoomThisDaySlots = Object.values(
      schedule.slots[dayViewing.toString()]
    ).find(room => room.find(slot => slot.room_id === roomID));

    let slots = <React.Fragment />;
    if (thisRoomThisDaySlots) {
      slots = thisRoomThisDaySlots.map(slot => {
        return (
          <ScheduleSlot 
            draggedSession={draggedSession} 
            slot={slot} 
            ripTime={ripTime} 
            startTime={startTime} 
            key={slot.id}
            changeDragged={changeDragged}
            csrf={csrf}
            sessions={sessions}
          />
        );
      });
    }

    return (
      <div
        className="schedule_column"
        key={"column " + room.name}
        style={{ height }}
      >
        <div className="schedule_column_head">{room.name}</div>
        <div className="schedule_time_slots">{slots}</div>
      </div>
    );
  }
}

ScheduleRow.propTypes = {
  height: PropTypes.string,
  schedule: PropTypes.object,
  dayViewing: PropTypes.number,
  startTime: PropTypes.number,
  ripTime: PropTypes.func,
  room: PropTypes.object,
  changeDragged: PropTypes.func,
  draggedSession: PropTypes.object,
  sessions: PropTypes.array
};

ScheduleRow.defaultProps = {sessions: []}

export default ScheduleRow