import React from "react"
import PropTypes from "prop-types"

import Nav from './Schedule/Nav';
import Ruler from './Schedule/Ruler';
import DayView from './Schedule/DayView';
import UnschedledArea from './Schedule/UnscheduledArea';

class Schedule extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      dayViewing: 1,
      startTime: 10,
      endTime: 17,
      counts: {},
      draggedSession: null
    }
  }

  changeDayView = day => {
    this.setState({ dayViewing: day })
  }

  ripTime = time => {
    // currently only returning hour. Need to refactor for minutes.
    return parseInt(time.split("T")[1].split(":")[0]);
  }

  determineHours = slots => {
    let hours = {
      startTime: this.state.startTime,
      endTime: this.state.endTime
    }

    let flattenedSlots = Object.values(slots).flat()
    
    flattenedSlots.forEach(day => {
      let flattenedDay = Object.values(day).flat() 
      flattenedDay.forEach(slot => {
        if (this.ripTime(slot.start_time) < hours.startTime) {
          hours.startTime = this.ripTime(slot.start_time);
        }
        if (this.ripTime(slot.end_time) > hours.endTime) {
          hours.endTime = this.ripTime(slot.end_time);
        }
      })
    })
    return hours;
  }

  changeDragged = programSession => {
    this.setState({draggedSession: programSession})
  }

  scheduleSession = (programSession, targetSlot ) => {
    let unscheduledSessions = this.state.unscheduledSessions.filter(session => {
      return session.id !== programSession.id
    })

    let targetDay = targetSlot.conference_day.toString();
    
    let schedule = Object.assign({}, this.state.schedule);
    let slot = Object.values(schedule.slots[targetDay]).flat().find(slot => slot.id === targetSlot.id)
    let previousSessionID = slot.program_session_id

    slot.program_session_id = programSession.id;

    if (programSession.slot) {
      this.unscheduleSession(programSession)
    }

    if (previousSessionID && previousSessionID !== slot.program_session_id) {
      let replacedSession = this.state.sessions.find(session => session.id === previousSessionID)
      unscheduledSessions.push(replacedSession)
    }
    this.setState({unscheduledSessions, schedule})
  }

  unscheduleSession = programSession => {
    let unscheduledSessions = this.state.unscheduledSessions.slice();
    let previousSlot = programSession.slot;

    let schedule = Object.assign({}, this.state.schedule)
    let day = previousSlot.conference_day.toString();

    let slot = Object.values(schedule.slots[day]).flat().find(slot => slot.id === previousSlot.id)

    slot.program_session_id = null;
    unscheduledSessions.push(Object.assign(programSession, {slot: null}))

    this.setState({unscheduledSessions, schedule})
  }

  componentDidMount() {
    let hours = this.determineHours(this.props.schedule.slots)
    this.setState(Object.assign(this.state, this.props, hours)) // doing this until I can hit the API here.
  }

  componentDidUpdate() {
    console.log(this.state)
  }

  render () {
    const { counts, dayViewing, startTime, endTime, schedule, sessions, unscheduledSessions, draggedSession, csrf } = this.state;
    return (
      <div className="schedule_grid">
        <Nav
          counts={counts}
          changeDayView={this.changeDayView}
          dayViewing={dayViewing}
        />
        <div className="grid_container">
          <Ruler startTime={startTime} endTime={endTime} />
          <DayView
            schedule={schedule}
            dayViewing={dayViewing}
            startTime={startTime}
            endTime={endTime}
            ripTime={this.ripTime}
            changeDragged={this.changeDragged}
            draggedSession={draggedSession}
            csrf={csrf}
            sessions={sessions}
            scheduleSession={this.scheduleSession}
          />
          <UnschedledArea
            unscheduledSessions={unscheduledSessions}
            sessions={sessions}
            changeDragged={this.changeDragged}
            draggedSession={draggedSession}
            csrf={csrf}
            unscheduleSession={this.unscheduleSession}
          />
        </div>
      </div>
    );
  }
}

Schedule.propTypes = {
  schedule: PropTypes.object,
  sessions: PropTypes.array,
  counts: PropTypes.object,
  unscheduledSessions: PropTypes.array,
  csrf: PropTypes.string
};

export default Schedule
