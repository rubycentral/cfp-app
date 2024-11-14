import React, { Component, Fragment } from 'react';
import PropTypes from 'prop-types';

import { ProgramSession } from './ProgramSession';
import { TimeSlotInfo } from './TimeSlotInfo';
import { TimeSlotModal } from './TimeSlotModal';
import { patchTimeSlot } from '../../apiCalls';

class ScheduleSlot extends Component {
  constructor(props) {
    super(props);
    this.state = {
      hoverDrag: false,
      modalShowing: false,
      title: this.props.slot.title || '',
      track: this.props.slot.track_id || '',
      presenter: this.props.slot.presenter || '',
      description: this.props.slot.description || '',
    };
  }

  onDragOver = (e) => {
    e.preventDefault();
    this.setState({ hoverDrag: true });
  };

  onDragLeave = (e) => {
    e.preventDefault();
    this.setState({ hoverDrag: false });
  };

  onDrop = (slot, e) => {
    e.preventDefault();
    const session = this.props.draggedSession;
    const { handleMoveSessionResponse, changeDragged } = this.props;

    if (session.slot) {
      if (session.slot.program_session_id === slot.program_session_id) {
        changeDragged(null);
        return;
      }
    }

    patchTimeSlot(slot, session)
      .then((response) => response.json())
      .then((data) => {
        const { errors } = data;

        if (errors) {
          this.props.showErrors(errors);
          return;
        }

        if (session.slot) {
          patchTimeSlot(session.slot, null)
            .then((response) => response.json())
            .then((data) => {
              const { sessions, slots, unscheduled_sessions } = data;
              handleMoveSessionResponse(sessions, unscheduled_sessions, slots, session);
            });
        } else {
          const { sessions, slots, unscheduled_sessions } = data;
          handleMoveSessionResponse(sessions, unscheduled_sessions, slots);
        }
        changeDragged(null);
        this.setState({ hoverDrag: false });
      })
      .catch((error) => console.error('Error:', error));
  };

  onDrag = (programSession) => {
    const { title, description, track, presenter } = this.state;
    this.props.changeDragged(
      Object.assign(programSession, {
        slot: Object.assign(this.props.slot, {
          title,
          description,
          track_id: track,
          presenter,
        }),
      })
    );
  };

  showModal = () => {
    if (!this.state.modalShowing) {
      this.setState({ modalShowing: true });
    }
  };

  closeModal = () => {
    this.setState({ modalShowing: false });
  };

  updateSlot = (e) => {
    const { name, value } = e.target;
    this.setState({
      [name]: value,
    });
  };

  render() {
    const {
      slot,
      ripTime,
      startTime,
      sessions,
      tracks,
      unscheduledSessions,
      handleMoveSessionResponse,
      sessionFormats,
      roomName,
    } = this.props;
    const { title, track, presenter, description } = this.state;

    const slotStartTime = ripTime(slot.start_time);
    const slotEndTime = ripTime(slot.end_time);
    let background = this.state.hoverDrag ? '#f9f6f1' : '#fff';

    const style = {
      top: (slotStartTime - startTime) * 90 + 'px',
      height: (slotEndTime - slotStartTime) * 90 + 'px',
      background,
    };

    let matchedSession;
    let session;

    if (slot.program_session_id) {
      matchedSession = sessions.find((session) => session.id === slot.program_session_id);
      session = <ProgramSession session={matchedSession} onDrag={this.onDrag} tracks={tracks} />;
    }
    let timeSlotInfo = <TimeSlotInfo slot={slot} tracks={tracks} />;

    return (
      <div
        className="schedule_slot"
        style={style}
        key={slot.id}
        onDragOver={(e) => this.onDragOver(e)}
        onDragLeave={(e) => this.onDragLeave(e)}
        onDrop={(e) => this.onDrop(slot, e)}
        onClick={this.showModal}
      >
        {session || timeSlotInfo}
        {this.state.modalShowing === true && (
          <TimeSlotModal
            slot={this.props.slot}
            matchedSession={matchedSession}
            unscheduledSessions={unscheduledSessions}
            tracks={tracks}
            closeModal={this.closeModal}
            sessions={sessions}
            handleMoveSessionResponse={handleMoveSessionResponse}
            sessionFormats={sessionFormats}
            title={title}
            track={track}
            presenter={presenter}
            description={description}
            updateSlot={this.updateSlot}
            roomName={roomName}
          />
        )}
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
  tracks: PropTypes.array,
  unscheduledSessions: PropTypes.array,
  showErrors: PropTypes.func,
  roomName: PropTypes.string,
};

export { ScheduleSlot };
