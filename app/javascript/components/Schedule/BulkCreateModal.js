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
    let rooms = this.state.rooms.slice()
    const room = e.target.name
    
    if (rooms.includes(room)) {
      rooms = rooms.filter(selectedRoom => selectedRoom !== room)
    } else {
      rooms.push(room)
    }

    this.setState({rooms})
  }

  changeInput = (e) => {
    const name = e.target.name
    this.setState({[name]: e.target.value})
  }

  previewSlots = () => {
    const { day, rooms, startTimes } = this.state;
    let duration = parseInt(this.state.duration)
    let slots = []
    
    startTimes.split(',').forEach(time => {
      let cleanedTime = time.replace(/\s/g, '').split(':')
      

      rooms.forEach(room => {
        let slot = {}
        let startTime = parseInt(time.replace(/\s/g, ''));
        slot.startTime = startTime;
        slot.endTime = startTime + (duration / 60);
        slot.day = day;
        slot.room = room;
        slots.push(slot)
      })
    })
    
    this.props.createTimeSlotPreviews(slots, this.state)
  }

  componentDidMount() {
    if (this.props.editState) {
      this.setState(this.props.editState)
    } else {
      this.setState({
        day: this.props.dayViewing
      })
    }
  }

  render() {
    const days = Object.keys(this.props.counts)
    const dayOptions = days.map(day => (
      <option key={'day '+day} value={day}>{day}</option>
    ))

    const rooms = this.props.rooms.map(room => {
      const checked = this.state.rooms.includes(room.id.toString())
      return (
        <div key={room.name}>
          <input 
            type='checkbox'
            name={room.id.toString()}
            checked={checked}
            onChange={this.changeRooms}
          />
          <span>{room.name}</span>
        </div>
      )
    })

    return (
      <div className='bulk-modal-container'>
        <div className='bulk-modal'>
          <div className='modal-header' >
            <h3>Bulk Generate Time Slots</h3>
          </div>
          <div className='modal-body'>
            <label>
              Day
              <select 
                className='full-width-input' 
                value={this.state.day} 
                onChange={this.changeDay} >
                  {dayOptions}
              </select>
            </label>
            <label>
              Rooms
              {rooms}
            </label>
            <label>
              Start Times
              <div>
                <input 
                  className='start-times full-width-input'
                  type='number'
                  name='startTimes'
                  value={this.state.startTimes}
                  onChange={this.changeInput}
                  placeholder='ex: 10:00, 11:00, 13:00'
                />
              </div>
            </label>
            <label>
              Duration
              <div>
                <input
                  className='start-times full-width-input'
                  type='number'
                  name='duration'
                  value={this.state.duration}
                  onChange={this.changeInput}
                />
              </div>
            </label>
          </div>
          <div className='modal-footer'>
            <button 
              className='btn btn-default bulk-cancel'
            onClick={this.props.closeBulkTimeSlotModal}>Cancel</button>
            <button 
              className='btn btn-success'
              onClick={this.previewSlots}
            >Preview</button>
          </div>
        </div>
      </div>
    )
  }
}

BulkCreateModal.propTypes = {
  closeBulkTimeSlotModal: PropTypes.func,
  dayViewing: PropTypes.number,
  counts: PropTypes.object,
  rooms: PropTypes.array,
  createTimeSlotPreview: PropTypes.func,
  editState: PropTypes.oneOfType([PropTypes.null, PropTypes.object])
}

BulkCreateModal.defaultProps = {
  rooms: []
}

export default BulkCreateModal;
