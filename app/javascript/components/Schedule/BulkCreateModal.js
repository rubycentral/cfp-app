import React from "react";
import PropTypes from "prop-types";

class BulkCreateModal extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      day: 1,
      rooms: [],
      startTimes: '',
      duration: ''
    }
  }

  changeDay = (e) => {
    this.setState({day: e.target.value})
  }

  changeRooms = (e) => {
    const rooms = this.state.rooms.slice()
  }

  componentDidMount() {
    this.setState({
      day: this.props.dayViewing
    })
  }

  render() {
    const days = Object.keys(this.props.counts)
    const dayOptions = days.map(day => (
      <option value={day}>{day}</option>
    ))

    return (
      <div className='bulk-modal-container'>
        <div className='bulk-modal' onClick={() => {}}>
          <div className='modal-header' >
            <h3>Bulk Generate Time Slots</h3>
          </div>
          <div className='modal-body'>
            <label>
              Day
              <select value={this.state.day} onChange={this.changeDay} >
                {dayOptions}
              </select>
            </label>

            <label>
              Rooms
            </label>
          </div>
        </div>
      </div>
    )
  }
}

BulkCreateModal.propTypes = {
  closeBulkTimeSlotModal: PropTypes.func,
  dayViewing: PropTypes.number,
  counts: PropTypes.object
}

export default BulkCreateModal;