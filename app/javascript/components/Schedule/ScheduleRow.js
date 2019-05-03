import React from "react";
import PropTypes from "prop-types"

import { patchTimeSlot } from "../../apiCalls";

class ScheduleRow extends React.Component {
  onDragOver = e => {
    e.preventDefault();
  };

  onDrop = slot => {
    const talk = this.props.draggedTalk;

    patchTimeSlot(slot, talk);

    this.props.changeDragged(null);
  };

  render() {
    const {
      height,
      room,
      startTime,
      ripTime,
      schedule,
      dayViewing
    } = this.props;

    const roomID = room.id;
    const thisRoomThisDaySlots = Object.values(
      schedule.slots[dayViewing.toString()]
    ).find(room => room.find(slot => slot.room_id === roomID));

    let slots = <React.Fragment />;
    if (thisRoomThisDaySlots) {
      slots = thisRoomThisDaySlots.map(slot => {
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
  room: PropTypes.object
};

export default ScheduleRow