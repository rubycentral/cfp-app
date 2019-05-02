import React from "react"
import PropTypes from "prop-types"

import Nav from './Schedule/Nav';
import Ruler from './Schedule/Ruler';
import DayView from './Schedule/DayView';

class Schedule extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      dayViewing: 1,
      startTime: 9,
      endTime: 19,
      counts: {},
    }
  }

  changeDayView = day => {
    this.setState({ dayViewing: day })
  }

  componentDidMount() {
    this.setState(Object.assign(this.state, this.props)) // doing this until I can hit the API here.
  }

  componentDidUpdate() {
    console.log(this.state)
  }

  render () {
    const { counts, dayViewing, startTime, endTime, schedule, sessions } = this.state;
    return (
      <div className='schedule_grid'> 
        <Nav 
          counts={counts} 
          changeDayView={this.changeDayView}
          dayViewing={dayViewing}
        />
        <div className='grid_container'>
          <Ruler startTime={startTime} endTime={endTime}/>
          <DayView 
            schedule={schedule}
            sessions={sessions}
            dayViewing={dayViewing}
            startTime={startTime}
            endTime={endTime}
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
};

export default Schedule
