import React, { Component } from "react"
import PropTypes from "prop-types"

import ScheduleColumn from './ScheduleColumn'

class DayView extends Component {
  render() {
    const {
      dayViewing,
      startTime,
      endTime,
      ripTime,
      changeDragged,
      draggedSession,
      csrf,
      sessions,
      tracks,
      previewSlots,
      rooms,
      slots,
      handleMoveSessionResponse,
      unscheduledSessions
    } = this.props

    let rows = rooms.map(room => {
      const height = (( endTime - startTime + 1) * 90) + 25 + 'px'
      return (
        <ScheduleColumn
          key={"day" + dayViewing + "room" + room.id}
          height={height}
          room={room}
          startTime={startTime}
          endTime={endTime}
          ripTime={ripTime}
          dayViewing={dayViewing}
          changeDragged={changeDragged}
          draggedSession={draggedSession}
          sessions={sessions}
          csrf={csrf}
          tracks={tracks}
          previewSlots={previewSlots}
          slots={slots}
          handleMoveSessionResponse={handleMoveSessionResponse}
          unscheduledSessions={unscheduledSessions}
        />
      )
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
  draggedSession: PropTypes.object,
  sessions: PropTypes.array,
  tracks: PropTypes.array,
  previewSlots: PropTypes.array,
  handleMoveSessionResponse: PropTypes.func,
  unscheduledSessions: PropTypes.array
}
DayView.defaultProps = {sessions: []}

export default DayView
