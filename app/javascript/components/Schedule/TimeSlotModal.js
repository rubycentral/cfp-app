import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { patchTimeSlot } from '../../apiCalls';

class TimeSlotModal extends Component {
  constructor(props) {
    super(props);
    this.state = {
      sessionSelected: this.props.matchedSession ? this.props.matchedSession : '',
    };
  }

  componentDidMount() {
    const { slot, matchedSession } = this.props;
  }

  changeSession = (e) => {
    let session = this.props.sessions.find((s) => s.title === e.target.value);
    if (!session) {
      this.setState({ sessionSelected: '' });
    } else {
      this.setState({ sessionSelected: session });
    }
  };

  close = () => {
    this.props.closeModal();
  };

  saveChanges = () => {
    const { sessionSelected } = this.state;
    const { closeModal, handleMoveSessionResponse, title, track, presenter, description } = this.props;

    let slot;
    if (!sessionSelected) {
      slot = Object.assign(this.props.slot, {
        title,
        track_id: track,
        presenter,
        description,
      });
    } else {
      slot = this.props.slot;
    }

    patchTimeSlot(slot, sessionSelected || null)
      .then((response) => response.json())
      .then((data) => {
        const { sessions, slots, unscheduled_sessions } = data;
        handleMoveSessionResponse(sessions, unscheduled_sessions, slots);
        closeModal();
      });
  };

  formatTime = (time) => {
    let hours = time.split('T')[1].split(':')[0];
    let amPm = hours < 12 ? ' am' : ' pm';
    if (parseInt(hours) > 12) {
      hours = (parseInt(hours) - 12).toString();
    }
    if (hours.charAt(0) === '0') {
      hours = hours.substr(1);
    }
    const minutes = time.split(':')[1];
    return hours + ':' + minutes + amPm;
  };

  render() {
    const { slot, matchedSession, unscheduledSessions, tracks, sessionFormats, roomName } = this.props;

    const { sessionSelected } = this.state;

    let sessionOptions;
    if (sessionSelected) {
      sessionOptions = matchedSession
        ? [matchedSession, ...unscheduledSessions]
        : [{ title: '' }, sessionSelected, ...unscheduledSessions.filter((s) => s.id !== sessionSelected.id)];
    } else {
      sessionOptions = [{ title: '' }, ...unscheduledSessions];
    }
    sessionOptions = sessionOptions.map((session) => (
      <option key={'session ' + session.id} value={session.title}>
        {session.title}
      </option>
    ));

    let sessionInfo;
    if (sessionSelected) {
      sessionInfo = (
        <>
          <label>
            Title:
            <p>{sessionSelected.title}</p>
          </label>
          <label>
            Track:
            <p>{tracks.find((track) => track.id === sessionSelected.track_id || 'No track').name}</p>
          </label>
          <label>
            Abstract:
            <p>{sessionSelected.abstract}</p>
          </label>
          <label>
            Recommended duration:
            <p>{sessionFormats.find((s) => s.id === sessionSelected.session_format_id).duration + ' minutes'}</p>
          </label>
        </>
      );
    }

    let timeSlotForm = (
      <>
        <label>
          Title:
          <input type="text" name="title" value={this.props.title} onChange={this.props.updateSlot} />
        </label>
        <label>
          Track:
          <select name="track" value={this.props.track} onChange={this.props.updateSlot}>
            <option value=""></option>
            {tracks.map((t) => (
              <option key={t.id} value={t.id}>
                {t.name}
              </option>
            ))}
          </select>
        </label>
        <label>
          Presenter:
          <input type="text" name="presenter" value={this.props.presenter} onChange={this.props.updateSlot} />
        </label>
        <label>
          Description:
          <textarea type="text" name="description" value={this.props.description} onChange={this.props.updateSlot} />
        </label>
      </>
    );

    return (
      <div className="modal-container">
        <div className="bulk-modal">
          <div className="modal-header">
            <h3>Edit Time Slot</h3>
            <span onClick={this.close} className="glyphicon glyphicon-remove" />
            <div className="room-data">
              <p>
                Day {slot.conference_day}, {this.formatTime(slot.start_time)} - {this.formatTime(slot.end_time)},{' '}
                {roomName}
              </p>
            </div>
          </div>
          <div className="modal-body">
            <label>
              Program Session
              <select value={this.state.sessionSelected.title} onChange={this.changeSession}>
                {sessionOptions}
              </select>
            </label>
            {sessionSelected ? sessionInfo : timeSlotForm}
          </div>
          <div className="modal-footer">
            <button className="btn btn-default" onClick={() => this.close()}>
              Cancel
            </button>
            <button className="btn btn-success" onClick={this.saveChanges}>
              Save
            </button>
          </div>
        </div>
      </div>
    );
  }
}

TimeSlotModal.propTypes = {};

export { TimeSlotModal };
