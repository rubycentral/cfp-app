import React from "react";
import PropTypes from "prop-types";

import ProgramSession from './ProgramSession';
import { patchTimeSlot } from "../../apiCalls";

class ScheduleSlot extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      hoverDrag: false
    }
  }
  
  onDragOver = e => {
    e.preventDefault()
    this.setState({ hoverDrag: true })
  };

  onDragLeave = e => {
    console.log('left')
    e.preventDefault()
    this.setState({ hoverDrag: false})
  }

  onDrop = slot => {
    const session = this.props.draggedSession;
    const { csrf, handleMoveSessionResponse, changeDragged } = this.props;
    
    if (session.slot) {
      if (session.slot.program_session_id === slot.program_session_id) {
        changeDragged(null)
        return
      }
    }
    
    patchTimeSlot(slot, session, csrf)
      .then((response) => response.json())
      .then(data => {
        const { sessions, slots, unscheduled_sessions } = data
        if (session.slot) {
          patchTimeSlot(session.slot, null, csrf)
          handleMoveSessionResponse(sessions, unscheduled_sessions, slots, session)
        } else {
          handleMoveSessionResponse(sessions, unscheduled_sessions, slots)
        }
        changeDragged(null);
        this.setState({ hoverDrag: false })
      })
      .catch(error => console.error("Error:", error));
  };

  onDrag = (programSession) => {
    this.props.changeDragged(Object.assign(programSession, {slot: this.props.slot}))
  }

  render() {
    const { slot, ripTime, startTime, sessions, tracks } = this.props;
    
    const slotStartTime = ripTime(slot.start_time);
    const slotEndTime = ripTime(slot.end_time);
    let background = this.state.hoverDrag ? '#f9f6f1' : '#fff'
    
    const style = {
      top: (slotStartTime - startTime) * 90 + "px",
      height: (slotEndTime - slotStartTime) * 90 + "px",
      background
    };

    let session = <React.Fragment/>
    if (slot.program_session_id) {
      let matchedSession = sessions.find(
        session => session.id === slot.program_session_id
      )
      session = <ProgramSession session={matchedSession} onDrag={this.onDrag} tracks={tracks} />
    }


    return (
      <div
        className="schedule_slot"
        style={style}
        key={slot.id}
        onDragOver={e => this.onDragOver(e)}
        onDragLeave={e => this.onDragLeave(e)}
        onDrop={() => this.onDrop(slot)}
      >
        {session}
      </div>
    );
  }
}

ScheduleSlot.propTypes = {
  slot: PropTypes.object,
  ripTime: PropTypes.func,
  startTime: PropTypes.number,
  changeDragged: PropTypes.func,
  draggedSession: PropTypes.object,
  handleMoveSessionResponse: PropTypes.func,
  tracks: PropTypes.array
}

export default ScheduleSlot
