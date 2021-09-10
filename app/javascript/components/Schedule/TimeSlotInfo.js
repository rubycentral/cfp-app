import React, { Component } from 'react';
import PropTypes from 'prop-types';

class TimeSlotInfo extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { slot, tracks } = this.props;

    const slotTrack = tracks.find((track) => track.id === slot.track_id);

    const bkgColor = slotTrack ? slotTrack.color : 'unset';
    const trackName = slotTrack ? slotTrack.name : '';

    return (
      <div className="slot_info_card">
        <div className="card_header" style={{ backgroundColor: bkgColor }}>
          {trackName}
        </div>
        <div className="card_body">
          <p>{slot.title}</p>
        </div>
      </div>
    );
  }
}

export { TimeSlotInfo };

TimeSlotInfo.propTypes = {
  slot: PropTypes.object,
  tracks: PropTypes.array,
};

TimeSlotInfo.defaultProps = { tracks: [] };
