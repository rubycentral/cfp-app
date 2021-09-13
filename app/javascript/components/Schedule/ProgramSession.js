import React, { Component } from 'react';
import PropTypes from 'prop-types';

class ProgramSession extends Component {
  constructor(props) {
    super(props);
  }

  drag = (session, e) => {
    this.props.onDrag(session);
    e.dataTransfer.setData('text', 'anything');
  };

  dragEnd = (e) => {
    e.preventDefault();
  };

  render() {
    const { session, tracks } = this.props;

    const sessionTrack = tracks.find((track) => track.id === session.track_id);

    const bkgColor = sessionTrack ? sessionTrack.color : '#fff';
    const trackName = sessionTrack ? sessionTrack.name : '';

    return (
      <div
        className="program_session_card"
        draggable={true}
        onDragStart={(e) => this.drag(session, e)}
        onDragEnd={(e) => this.dragEnd(e)}
      >
        <div className="card_header" style={{ backgroundColor: bkgColor }}>
          {trackName}
        </div>
        <div className="card_body">
          <p>{session.title}</p>
        </div>
      </div>
    );
  }
}

export { ProgramSession };

ProgramSession.propTypes = {
  session: PropTypes.object,
  onDrag: PropTypes.func,
  tracks: PropTypes.array,
};

ProgramSession.defaultProps = { tracks: [] };
