import React from "react"
import PropTypes from "prop-types"
class DayView extends React.Component {
  render() {
    const { schedule, sessions } = this.props;
    let rows = schedule.rooms.map(room => {
      return <div className='schedule_column' key={'column ' + room.name}>
        <div className=''>{room.name}</div>
      </div>
    })

    return (
      <div>
        {rows}
      </div>
    )
  }
}

DayView.propTypes = {
  schedule: PropTypes.object,
  sessions: PropTypes.array
}
DayView.defaultProps = {schedule: {rooms: []}}

export default DayView