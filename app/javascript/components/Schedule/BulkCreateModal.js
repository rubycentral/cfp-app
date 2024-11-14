import React, { Component } from 'react';
import PropTypes from 'prop-types';

class BulkCreateModal extends Component {
  constructor(props) {
    super(props);
    this.state = {
      day: 1,
      rooms: [],
      startTimes: '',
      duration: '',
      timeError: false,
    };
  }

  changeDay = (e) => {
    this.setState({ day: e.target.value });
  };

  changeRooms = (e) => {
    let rooms = this.state.rooms.slice();
    const room = e.target.name;

    if (rooms.includes(room)) {
      rooms = rooms.filter((selectedRoom) => selectedRoom !== room);
    } else {
      rooms.push(room);
    }

    this.setState({ rooms });
  };

  changeInput = (e) => {
    const name = e.target.name;
    this.setState({ [name]: e.target.value }, () => {
      name === 'startTimes' && this.validateTimes();
    });
  };

  validateTimes = () => {
    const { startTimes } = this.state;
    let valid = true;
    startTimes.split(',').forEach((time) => {
      const cleanedTime = time.replace(/\s/g, '');
      if (time.includes(':')) {
        const validTime = /^([0-1]?[0-9]|2[0-3]):([0-5][0-9])(:[0-5][0-9])?$/.test(cleanedTime);

        if (!validTime) {
          valid = false;
        }
      } else {
        if (parseInt(cleanedTime) > 24 || parseInt(cleanedTime) < 0) {
          valid = false;
        }
      }
    });

    if (!valid) {
      this.setState({ timeError: true });
    } else {
      this.setState({ timeError: false });
    }
  };

  previewSlots = () => {
    const { day, rooms, startTimes } = this.state;
    const { createTimeSlotPreviews } = this.props;
    let duration = parseInt(this.state.duration);
    let slots = [];

    startTimes.split(',').forEach((time) => {
      let cleanedStartTime = time.replace(/\s/g, '').split(':');
      if (cleanedStartTime.length > 1) {
        cleanedStartTime = parseInt(cleanedStartTime[0]) + parseInt(cleanedStartTime[1]) / 60;
      } else {
        cleanedStartTime = parseInt(cleanedStartTime[0]);
      }

      rooms.forEach((room) => {
        let slot = {};
        slot.startTime = cleanedStartTime;
        slot.endTime = cleanedStartTime + duration / 60;
        slot.day = day;
        slot.room = room;
        slots.push(slot);
      });
    });

    createTimeSlotPreviews(slots, this.state);
  };

  componentDidMount() {
    const { editState, dayViewing } = this.props;

    if (editState) {
      this.setState(editState);
    } else {
      this.setState({
        day: dayViewing,
      });
    }
  }

  render() {
    let { sessionFormats, closeBulkTimeSlotModal, counts } = this.props;
    let { timeError, day, startTimes, duration } = this.state;

    const days = Object.keys(counts);
    const dayOptions = days.map((day) => (
      <option key={'day ' + day} value={day}>
        {day}
      </option>
    ));

    const rooms = this.props.rooms.map((room) => {
      const checked = this.state.rooms.includes(room.id.toString());
      return (
        <div key={room.name}>
          <input
            type="checkbox"
            name={room.id.toString()}
            checked={checked}
            onChange={this.changeRooms}
            className="bulk-checkbox"
          />
          <span>{room.name}</span>
        </div>
      );
    });

    const denoteRequired = (stateKey) => {
      if (this.state[stateKey].length < 1) {
        return <span className="required">*</span>;
      }
    };

    sessionFormats = sessionFormats.slice();
    sessionFormats.unshift({});
    const formats = sessionFormats.map((format) => {
      const text = format.name ? format.name + ' (' + format.duration + ' minutes)' : '';

      return (
        <option key={'format' + format.id} value={format.duration}>
          {text}
        </option>
      );
    });

    const previewDisabled = () => {
      const { rooms, startTimes, duration, timeError } = this.state;

      return rooms.length < 1 || startTimes.length < 1 || duration.length < 1 || timeError;
    };

    return (
      <div className="modal-container">
        <div className="bulk-modal">
          <div className="modal-header">
            <h3>Bulk Generate Time Slots</h3>
          </div>
          <div className="modal-body">
            <label>
              Day
              <select className="full-width-input" value={day} onChange={this.changeDay}>
                {dayOptions}
              </select>
            </label>
            <label>
              Rooms
              {denoteRequired('rooms')}
              {rooms}
            </label>
            <label>
              Start Times
              {denoteRequired('startTimes')}
              {timeError && <p className="error">Please only enter times between 0:00 and 23:59</p>}
              <div>
                <input
                  className="start-times full-width-input"
                  type="text"
                  name="startTimes"
                  value={startTimes}
                  onChange={this.changeInput}
                  placeholder="ex: 10:00, 11:00, 13:00"
                />
              </div>
            </label>
            <label>
              Duration (minutes)
              {denoteRequired('duration')}
              <div>
                <input
                  className="start-times minutes-input"
                  type="number"
                  name="duration"
                  value={duration}
                  onChange={this.changeInput}
                />
                <select className="session-select" name="duration" onChange={this.changeInput}>
                  {formats}
                </select>
              </div>
            </label>
          </div>
          <div className="modal-footer">
            <button className="btn btn-default bulk-cancel" onClick={closeBulkTimeSlotModal}>
              Cancel
            </button>
            <button className="btn btn-success" onClick={this.previewSlots} disabled={previewDisabled()}>
              Preview
            </button>
          </div>
        </div>
      </div>
    );
  }
}

BulkCreateModal.propTypes = {
  closeBulkTimeSlotModal: PropTypes.func,
  dayViewing: PropTypes.number,
  counts: PropTypes.object,
  rooms: PropTypes.array,
  createTimeSlotPreview: PropTypes.func,
  editState: PropTypes.oneOfType([
    PropTypes.arrayOf(PropTypes.object),
    PropTypes.object
  ]),
};

BulkCreateModal.defaultProps = {
  rooms: [],
};

export { BulkCreateModal };
