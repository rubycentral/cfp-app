import React from "react"
import PropTypes from "prop-types"

import ScheduleRow from './ScheduleRow';

class DayView extends React.Component {
  render() {
    const {
      schedule,
      dayViewing,
      startTime,
      endTime,
      ripTime,
      changeDragged,
      draggedSession
    } = this.props;

    let rows = schedule.rooms.map(room => {
      const height = (( endTime - startTime + 1) * 90 + 40) + 'px'
      return (
        <ScheduleRow
          key={"day" + dayViewing + "room" + room.id}
          height={height}
          room={room}
          startTime={startTime}
          endTime={endTime}
          ripTime={ripTime}
          schedule={schedule}
          dayViewing={dayViewing}
          changeDragged={changeDragged}
          draggedSession={draggedSession}
        />
      );
    })

    return (
      <React.Fragment>
        {rows}
      </React.Fragment>
    )
  }
}

DayView.propTypes = {
  schedule: PropTypes.object,
  dayViewing: PropTypes.number,
  startTime: PropTypes.number,
  endTime: PropTypes.number,
  ripTime: PropTypes.func,
  changeDragged: PropTypes.func,
  draggedSession: PropTypes.object
}
DayView.defaultProps = {schedule: {rooms: []}}

export default DayView