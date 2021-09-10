import React, { Component } from 'react';
import PropTypes from 'prop-types';

import { ProgramSession } from './ProgramSession';
import { patchTimeSlot } from '../../apiCalls';

class UnscheduledArea extends Component {
  constructor(props) {
    super(props);

    this.state = {
      searchInput: '',
      isHidden: false,
    };
  }

  handleChange = (e) => {
    this.setState({ searchInput: e.target.value });
  };

  clearInput = () => {
    this.setState({ searchInput: '' });
  };

  changeHiddenState = () => {
    this.setState({ isHidden: !this.state.isHidden });
  };

  onDrag = (programSession) => {
    this.props.changeDragged(programSession);
  };

  onDragOver = (e) => {
    e.preventDefault();
  };

  onDrop = (e) => {
    e.preventDefault();
    const { draggedSession, tracks } = this.props;

    patchTimeSlot(draggedSession.slot, null)
      .then((response) => response.json())
      .then((data) => {
        const { sessions, slots, unscheduled_sessions } = data;
        this.props.handleMoveSessionResponse(sessions, unscheduled_sessions, slots);
        this.props.changeDragged(null);
      })
      .catch((error) => console.error('Error:', error));
  };

  render() {
    const { sessions, unscheduledSessions, tracks } = this.props;
    const { searchInput, isHidden } = this.state;
    let display = isHidden ? 'none' : '';
    let filteredSessions = unscheduledSessions.filter((session) => {
      const titleMatch = session.title.toLowerCase().includes(searchInput.toLowerCase());
      let trackMatch;
      if (session.track_id) {
        let track = tracks.find((track) => track.id === session.track_id);
        trackMatch = track.name.toLowerCase().includes(searchInput.toLowerCase());
      }

      return titleMatch || trackMatch;
    });

    let unscheduledSessionCards = filteredSessions.map((session) => (
      <ProgramSession key={session.id} session={session} onDrag={this.onDrag} tracks={tracks} />
    ));

    return (
      <div className="unscheduled_area" onDrop={(e) => this.onDrop(e)} onDragOver={(e) => this.onDragOver(e)}>
        <div className="header_wrapper" onClick={this.changeHiddenState}>
          <h3>Unscheduled Sessions</h3>
          <span className="badge">
            {unscheduledSessions.length}/{sessions.length}{' '}
          </span>
        </div>
        <div className="unscheduled_sessions" style={{ display: display }}>
          <div className="search-sessions-wrapper">
            <label>Search:</label>
            <input type="text" value={searchInput} onChange={(e) => this.handleChange(e)} />
            <span onClick={this.clearInput} className="glyphicon glyphicon-remove-circle"></span>
          </div>
          <div>{unscheduledSessionCards}</div>
        </div>
      </div>
    );
  }
}

UnscheduledArea.propTypes = {
  unscheduledSessions: PropTypes.array,
  sessions: PropTypes.array,
  changeDragged: PropTypes.func,
  draggedSession: PropTypes.object,
  tracks: PropTypes.array,
  handleMoveSessionResponse: PropTypes.func,
};

UnscheduledArea.defaultProps = {
  unscheduledSessions: [],
  sessions: [],
};

export { UnscheduledArea };
