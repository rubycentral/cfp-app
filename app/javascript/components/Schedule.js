import React from "react"
import PropTypes from "prop-types"

class Schedule extends React.Component {
  render () {
    console.log('here!')
    return (
      <div>
        <h1>New Schedule</h1>
        <section>
          <h2>Schedule:</h2>
          <div>{JSON.stringify(this.props.schedule, null, 2)}</div>
        </section>
        <section>
          <h2>Sessions:</h2>
          <div>{JSON.stringify(this.props.sessions, null, 2)}</div>
        </section>
        <section>
          <h2>Counts:</h2>
          <div>{JSON.stringify(this.props.counts, null, 2)}</div>
        </section>
        <section>
          <h2>Unscheduled Sessions:</h2>
          <div>{JSON.stringify(this.props.unscheduledSessions, null, 2)}</div>
        </section>
      </div>
    );
  }
}

Schedule.propTypes = {
  schedule: PropTypes.object,
  sessions: PropTypes.array,
  counts: PropTypes.object,
  unscheduledSessions: PropTypes.array,
};
export default Schedule
