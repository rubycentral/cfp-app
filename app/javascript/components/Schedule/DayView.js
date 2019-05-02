import React from "react"
import PropTypes from "prop-types"
class DayView extends React.Component {
  render() {
    const { schedule, sessions, dayViewing, startTime, endTime } = this.props;
    let rows = schedule.rooms.map(room => {
      const height = (( endTime - startTime + 1) * 90 + 40) + 'px'

      return <div className='schedule_column' key={'column ' + room.name} style={{height}}>
        <div className='schedule_column_head'>{room.name}</div>
        <div className='schedule_time_slots'></div>
      </div>
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
  sessions: PropTypes.array,
  dayViewing: PropTypes.number,
  startTime: PropTypes.number,
  endTime: PropTypes.number
}
DayView.defaultProps = {schedule: {rooms: []}}

export default DayView