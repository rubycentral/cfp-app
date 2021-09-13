import React, { Component } from 'react';
import PropTypes from 'prop-types';

class Ruler extends Component {
  render() {
    const { startTime, endTime } = this.props;
    let hours = [];
    for (let i = Math.floor(startTime); i <= Math.floor(endTime); i++) {
      let time;
      if (i > 12) {
        time = i - 12 + ':00 pm';
      } else {
        time = i + ':00 am';
      }
      hours.push(time);
    }
    let ticks = hours.map((hour) => (
      <li className="ruler_tick" key={hour}>
        {hour}
      </li>
    ));

    return <ul className="schedule_ruler">{ticks}</ul>;
  }
}

Ruler.propTypes = {
  startTime: PropTypes.number,
  endTime: PropTypes.number,
};

export { Ruler };
