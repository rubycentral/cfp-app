import React, { Component } from 'react';
import PropTypes from 'prop-types';

class Nav extends Component {
  render() {
    const { changeDayView, counts, dayViewing, slots } = this.props;

    const navTabs = Object.keys(counts).map((dayNumber) => {
      let allSlots = slots.filter((slot) => slot.conference_day == dayNumber);
      let bookedSlots = allSlots.filter((slot) => slot.program_session_id);

      return (
        <li
          onClick={() => changeDayView(parseInt(dayNumber))}
          key={'day-tab ' + dayNumber}
          className={dayNumber == dayViewing ? 'active' : ''}
        >
          <span>Day {dayNumber}</span>
          <span className="badge">
            {bookedSlots.length}/{allSlots.length}{' '}
          </span>
        </li>
      );
    });

    return <ul className="schedule_nav">{navTabs}</ul>;
  }
}

Nav.propTypes = {
  changeDayView: PropTypes.func,
  counts: PropTypes.object,
  dayViewing: PropTypes.number,
  schedule: PropTypes.object,
};

export { Nav };
