import React from "react";
import PropTypes from "prop-types";

import Nav from "./Schedule/Nav";
import Ruler from "./Schedule/Ruler";
import DayView from "./Schedule/DayView";
import UnscheduledArea from "./Schedule/UnscheduledArea";
import GenerateGridButton from "./Schedule/GenerateGridButton";
import BulkCreateModal from "./Schedule/BulkCreateModal";
import BulkGenerateConfirm from "./Schedule/BulkGenerateConfirm";

import { postBulkTimeSlots } from "../apiCalls";

class Schedule extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      dayViewing: 1,
      startTime: 10,
      endTime: 17,
      counts: {},
      draggedSession: null,
      slots: [],
      rooms: [],
      bulkTimeSlotModalOpen: false,
      previewSlots: [],
      bulkTimeSlotModalEditState: null,
    };
  }

  changeDayView = day => {
    this.setState({ dayViewing: day });
  };

  ripTime = time => {
    // currently only returning hour. Need to refactor for minutes.
    const hours =  parseInt(time.split("T")[1].split(":")[0]);
    const minutes = parseInt(time.split(':')[1]) / 60
    return hours + minutes
  };

  determineHours = slots => {
    let hours = {
      startTime: this.state.startTime,
      endTime: this.state.endTime
    };

    slots.forEach(slot => {
      if (this.ripTime(slot.start_time) < hours.startTime) {
        hours.startTime = this.ripTime(slot.start_time);
      }
      if (this.ripTime(slot.end_time) > hours.endTime) {
        hours.endTime = this.ripTime(slot.end_time);
      }
    });
    return hours;
  };

  changeDragged = programSession => {
    this.setState({ draggedSession: programSession });
  };

  scheduleSession = (programSession, targetSlot) => {
    let unscheduledSessions = this.state.unscheduledSessions.filter(session => {
      return session.id !== programSession.id;
    });

    if (programSession.id === targetSlot.program_session_id) {
      return;
    }

    let targetDay = targetSlot.conference_day.toString();

    let schedule = Object.assign({}, this.state.schedule);
    let slot = Object.values(schedule.slots[targetDay])
      .flat()
      .find(slot => slot.id === targetSlot.id);
    let previousSessionID = slot.program_session_id;

    slot.program_session_id = programSession.id;

    if (programSession.slot) {
      this.unscheduleSession(programSession);
    }

    if (previousSessionID && previousSessionID !== slot.program_session_id) {
      let replacedSession = this.state.sessions.find(
        session => session.id === previousSessionID
      );
      unscheduledSessions.push(replacedSession);
    }

    this.setState({ unscheduledSessions, schedule });
  };

  unscheduleSession = programSession => {
    let unscheduledSessions = this.state.unscheduledSessions.slice();
    let previousSlot = programSession.slot;

    let schedule = Object.assign({}, this.state.schedule);
    let day = previousSlot.conference_day.toString();

    let slot = Object.values(schedule.slots[day])
      .flat()
      .find(slot => slot.id === previousSlot.id);

    slot.program_session_id = null;
    unscheduledSessions.push(Object.assign(programSession, { slot: null }));

    this.setState({ unscheduledSessions, schedule });
  };

  openBulkTimeSlotModal = () => {
    this.setState({
      bulkTimeSlotModalOpen: true,
      previewSlots: []
    })
  }

  closeBulkTimeSlotModal = (e) => {
    e.preventDefault()
    this.setState({
      previewSlots: [], 
      bulkTimeSlotModalEditState: null,
      bulkTimeSlotModalOpen: false
    })
  }

  cancelBulkPreview = () => {
    this.setState({
      previewSlots: [],
      bulkTimeSlotModalEditState: null
    })
  }

  createTimeSlotPreviews = (previewSlots, bulkTimeSlotModalEditState) => {
    this.setState({
      previewSlots, 
      bulkTimeSlotModalEditState, 
      bulkTimeSlotModalOpen: false,
      dayViewing: parseInt(bulkTimeSlotModalEditState.day)
    })
  }

  requestBulkTimeSlotCreate = () => {
    const {csrf, schedule, bulkTimeSlotModalEditState} = this.state;
    const path = schedule.bulk_generate_path;
    const {day, duration, rooms, startTimes} = bulkTimeSlotModalEditState;

    // the API expects time strings to have a minutes declaration, this following code adds a minute decaration to each time in a string, if needed. 
    const formattedTimes = startTimes.replace(/\s/g, '').split(',').map(time => {
      if (time.split(':').length > 1) {
        return time
      } else {
        return time + ':00'
      }
    }).join(', ')

    postBulkTimeSlots(path, day, rooms, duration, formattedTimes, csrf)
      .then(response => response.json())
      .then(data => console.log(data))
      .catch(err => console.log('Error: ', err))
  }

  componentDidMount() {
    console.log(this.props)
    let hours = this.determineHours(this.props.slots);
    const trackColors = palette("tol-rainbow", this.props.tracks.length);
    this.props.tracks.forEach((track, i) => {
      track.color = "#" + trackColors[i];
    });

    this.setState(Object.assign(this.state, this.props, hours)); // doing this until I can hit the API here.
  }

  componentDidUpdate() {
    console.log(this.state);
  }

  render() {
    const {
      counts,
      dayViewing,
      startTime,
      endTime,
      schedule,
      sessions,
      unscheduledSessions,
      draggedSession,
      csrf,
      tracks,
      bulkTimeSlotModalOpen,
      bulkTimeSlotModalEditState,
      previewSlots,
      slots,
      rooms
    } = this.state;

    const headers = rooms.map(room => (
      <div className="schedule_column_head" key={'column_head_' + room.name}>
        {room.name}
      </div>
    ));

    const headersMinWidth = (180 * rooms.length) + 'px';

    const bulkTimeSlotModal = bulkTimeSlotModalOpen && <BulkCreateModal 
      closeBulkTimeSlotModal={this.closeBulkTimeSlotModal}
      dayViewing={dayViewing}
      counts={counts}
      rooms={rooms}
      createTimeSlotPreviews={this.createTimeSlotPreviews}
      editState={bulkTimeSlotModalEditState}
    />

    return (
      <div className="schedule_grid">
        {bulkTimeSlotModal}
        <div className='nav_wrapper'>
          <Nav
            counts={counts}
            changeDayView={this.changeDayView}
            dayViewing={dayViewing}
            slots={slots}
          />
          <GenerateGridButton
            dayViewing={dayViewing}
            generateGridPath={this.props.bulk_path}
            openBulkTimeSlotModal={this.openBulkTimeSlotModal}
          />
        </div>
        <div className="grid_headers_wrapper" style={{'minWidth': headersMinWidth}}>{headers}</div>
        {/* <div className="grid_container">
          {previewSlots.length > 0 && <BulkGenerateConfirm 
            cancelBulkPreview={this.cancelBulkPreview}
            openBulkTimeSlotModal={this.openBulkTimeSlotModal}
            requestBulkTimeSlotCreate={this.requestBulkTimeSlotCreate}
          />}
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
            tracks={tracks}
            previewSlots={previewSlots}
          />
          <UnscheduledArea
            unscheduledSessions={unscheduledSessions}
            sessions={sessions}
            changeDragged={this.changeDragged}
            draggedSession={draggedSession}
            csrf={csrf}
            unscheduleSession={this.unscheduleSession}
            tracks={tracks}
          />
        </div> */}
      </div>
    );
  }
}

Schedule.propTypes = {
  schedule: PropTypes.object,
  sessions: PropTypes.array,
  counts: PropTypes.object,
  unscheduledSessions: PropTypes.array,
  csrf: PropTypes.string,
  tracks: PropTypes.array
};

Schedule.defaultProps = { schedule: { rooms: [] }};

export default Schedule;
