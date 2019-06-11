import React, { Component, Fragment } from "react"
import PropTypes from "prop-types"

import ProgramSession from './ProgramSession'
import TimeSlotModal from './TimeSlotModal'
import { patchTimeSlot } from "../../apiCalls"

class ScheduleSlot extends Component {
  constructor(props) {
    super(props)
    this.state = {
      hoverDrag: false,
      modalShowing: false
    }
  }
  
  onDragOver = e => {
    e.preventDefault()
    this.setState({ hoverDrag: true })
  }

  onDragLeave = e => {
    e.preventDefault()
    this.setState({ hoverDrag: false})
  }

  onDrop = slot => {
    const session = this.props.draggedSession
    const { csrf, handleMoveSessionResponse, changeDragged } = this.props
    
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
        changeDragged(null)
        this.setState({ hoverDrag: false })
      })
      .catch(error => console.error("Error:", error))
  }

  onDrag = (programSession) => {
    this.props.changeDragged(Object.assign(programSession, {slot: this.props.slot}))
  }

  showModal = () => {
    if (!this.state.modalShowing) {
      this.setState({modalShowing: true})
    }
  }

  closeModal = () => {
    this.setState({modalShowing: false})
  }

  render() {
    const { slot, ripTime, startTime, sessions, tracks, csrf, unscheduledSessions, handleMoveSessionResponse, sessionFormats } = this.props
    
    const slotStartTime = ripTime(slot.start_time)
    const slotEndTime = ripTime(slot.end_time)
    let background = this.state.hoverDrag ? '#f9f6f1' : '#fff'
    
    const style = {
      top: (slotStartTime - startTime) * 90 + "px",
      height: (slotEndTime - slotStartTime) * 90 + "px",
      background
    }

    let matchedSession
    let session = <Fragment/>
    if (slot.program_session_id) {
      matchedSession = sessions.find(
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
        onClick={this.showModal}
      >
        {session}
        {this.state.modalShowing === true && <TimeSlotModal 
          csrf={csrf} 
          slot={this.props.slot} 
          matchedSession={matchedSession} 
          unscheduledSessions={unscheduledSessions} 
          tracks={tracks} 
          closeModal={this.closeModal}
          sessions={sessions}
          handleMoveSessionResponse={handleMoveSessionResponse}
          sessionFormats={sessionFormats}
        />}
      </div>
    )
  }
}

ScheduleSlot.propTypes = {
  slot: PropTypes.object,
  ripTime: PropTypes.func,
  startTime: PropTypes.number,
  changeDragged: PropTypes.func,
  draggedSession: PropTypes.object,
  handleMoveSessionResponse: PropTypes.func,
  tracks: PropTypes.array,
  unscheduledSessions: PropTypes.array
}

export default ScheduleSlot
