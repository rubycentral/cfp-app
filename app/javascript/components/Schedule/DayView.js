import React from "react"
import PropTypes from "prop-types"

import {patchTimeSlot} from '../../apiCalls';

class DayView extends React.Component {
  onDragOver = e => {
    e.preventDefault()
  }

  onDrop = (slot) => {
    const talk = this.props.draggedTalk;
    
    patchTimeSlot(slot, talk)

    this.props.changeDragged(null) 
  }

  render() {
    const { schedule, dayViewing, startTime, endTime, ripTime } = this.props;
    let rows = schedule.rooms.map(room => {
      const height = (( endTime - startTime + 1) * 90 + 40) + 'px'
      const roomID = room.id;
      const thisRoomThisDaySlots = Object.values(schedule.slots[dayViewing.toString()]).find(room => room.find(slot => slot.room_id === roomID)) 

      let slots = <React.Fragment></React.Fragment>;
      if (thisRoomThisDaySlots) {
        slots = thisRoomThisDaySlots.map(slot => {
          const slotStartTime = ripTime(slot.start_time);
          const slotEndTime = ripTime(slot.end_time);

          const style = {
            "top": ((slotStartTime - startTime) * 90) + 'px',
            "height": ((slotEndTime - slotStartTime) * 90) +'px'
          }

          return (
            <div 
              className='schedule_slot' 
              style={style} 
              key={slot.id}
              onDragOver={e => this.onDragOver(e)}
              onDrop={() => this.onDrop(slot)}  
            >

            </div>
          )
        })
      }

      return <div className='schedule_column' key={'column ' + room.name} style={{height}}>
        <div className='schedule_column_head'>{room.name}</div>
        <div className='schedule_time_slots'>
          {slots}
        </div>
      </div>
    })

    return (
      <React.Fragment>
        {rows}
      </React.Fragment>
    )
  }
}

DayView.propTypes = {
  schedule: PropTypes.object,
  dayViewing: PropTypes.number,
  startTime: PropTypes.number,
  endTime: PropTypes.number,
  ripTime: PropTypes.func,
  changeDragged: PropTypes.func
}
DayView.defaultProps = {schedule: {rooms: []}}

export default DayView