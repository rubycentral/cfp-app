import React from "react";
import PropTypes from "prop-types"

import ScheduleSlot from './ScheduleSlot';
import Preview from './Preview';

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
      sessions,
      scheduleSession,
      tracks,
      previewSlots
    } = this.props;

    const roomID = room.id;

    const previews = previewSlots.filter(preview => {
      return parseInt(preview.room) === roomID && preview.day === dayViewing
    }).map(preview => {
      return <Preview preview={preview} startTime={startTime} />
    })

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
            scheduleSession={scheduleSession}
            tracks={tracks}
          />
        );
      });
    }
    
    return (
      <React.Fragment>
        <div
          className="schedule_column"
          key={"column " + room.name}
          style={{ height }}
        >
          <div className="schedule_time_slots">
            {previews}
            {slots}
          </div>
        </div>
      </React.Fragment>
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
  sessions: PropTypes.array,
  scheduleSession: PropTypes.func,
  tracks: PropTypes.array,
  previewSlots: PropTypes.array
};

ScheduleRow.defaultProps = {sessions: []}

export default ScheduleRow
