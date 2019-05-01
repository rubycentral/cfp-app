import React from "react"
import PropTypes from "prop-types"

import Nav from './Schedule/Nav';

class Schedule extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      dayViewing: 1,
      startTime: 7,
      endTime: 19,
      counts: {}
    }
  }

  changeDayView = day => {
    this.setState({ dayViewing: day })
  }

  componentDidMount() {
    this.setState(Object.assign(this.state, this.props), console.log(this.state)) // doing this until I can hit the API here.
  }

  render () {
    const { counts, dayViewing } = this.state;
    return (
      <div className='schedule_grid'> 
        <Nav 
          counts={counts} 
          changeDayView={this.changeDayView}
          dayViewing={dayViewing}
        />
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
