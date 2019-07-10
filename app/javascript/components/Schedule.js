import React, { Component } from "react"
import PropTypes from "prop-types"

import Nav from "./Schedule/Nav"
import Ruler from "./Schedule/Ruler"
import DayView from "./Schedule/DayView"
import UnscheduledArea from "./Schedule/UnscheduledArea"
import GenerateGridButton from "./Schedule/GenerateGridButton"
import BulkCreateModal from "./Schedule/BulkCreateModal"
import BulkGenerateConfirm from "./Schedule/BulkGenerateConfirm"
import Alert from './Schedule/Alert'

import { postBulkTimeSlots } from "../apiCalls"

class Schedule extends Component {
  constructor(props) {
    super(props)
    this.state = {
      dayViewing: 1,
      startTime: 10,
      endTime: 17,
      counts: {},
      draggedSession: null,
      slots: [],
      rooms: [],
      sessionFormats: [],
      bulkTimeSlotModalOpen: false,
      previewSlots: [],
      bulkTimeSlotModalEditState: null,
      errorMessages: [],
      bulkErrorMessages: [],
    }
  }

  changeDayView = day => {
    this.setState({ dayViewing: day })
  }

  ripTime = time => {
    const hours =  parseInt(time.split("T")[1].split(":")[0])
    const minutes = parseInt(time.split(':')[1]) / 60
    return hours + minutes
  }

  determineHours = slots => {
    let hours = {
      startTime: 12,
      endTime: 12
    }

    slots.forEach(slot => {
      if (this.ripTime(slot.start_time) < hours.startTime) {
        hours.startTime = this.ripTime(slot.start_time)
      }
      if (this.ripTime(slot.end_time) > hours.endTime) {
        hours.endTime = this.ripTime(slot.end_time)
      }
    })
    return hours
  }

  changeDragged = programSession => {
    this.setState({ draggedSession: programSession })
  }

  handleMoveSessionResponse = ( sessions, unscheduledSessions, slots, session ) => {
    if (session) {
      slots.forEach(slot => {
        if (slot.id === session.slot.id) {
          slot.program_session_id = null
        }
      })
    }

    this.setState({ sessions, unscheduledSessions, slots })
  }

  openBulkTimeSlotModal = () => {
    this.setState({
      bulkTimeSlotModalOpen: true,
      previewSlots: []
    })
  }

  closeBulkTimeSlotModal = (e) => {
    e.preventDefault()
    this.setState({
      previewSlots: [], 
      bulkTimeSlotModalEditState: null,
      bulkTimeSlotModalOpen: false
    })
  }

  cancelBulkPreview = () => {
    let hours = this.determineHours(this.state.slots)
    this.setState({
      previewSlots: [],
      bulkTimeSlotModalEditState: null,
      ...hours
    })
  }

  findTimeSlotConflicts = (previewSlots) => {
    const { slots } = this.state
    let conflicts = []

    previewSlots.forEach(ps => {
      slots.forEach(s => {
        let sameDaySameRoom = s.room_id === parseInt(ps.room) && s.conference_day === ps.day

        if (sameDaySameRoom) {
          let timeConflict = this.determineTimeConflict(ps, this.ripTime(s.start_time), this.ripTime(s.end_time))
          if (timeConflict) {
            conflicts.push(s)
          }
        }
      })

      previewSlots.forEach(preview => {
        if (Object.is(ps, preview)) { return }
        let sameDaySameRoom = parseInt(preview.room) === parseInt(ps.room) && preview.day === ps.day

        if (sameDaySameRoom) {
          let timeConflict = this.determineTimeConflict(ps, preview.startTime, preview.endTime)
          
          if (timeConflict) {
            conflicts.push(Object.assign(preview, { previewConflict: true }))
          }
        }
      })
      
    })

    return conflicts
  }

  determineTimeConflict = (previewSlot, compareStartTime, compareEndTime) => {
    return previewSlot.startTime > compareStartTime && previewSlot.startTime < compareEndTime || previewSlot.endTime > compareStartTime && previewSlot.startTime < compareEndTime
  }

  handleConflicts = (conflicts, bulkTimeSlotModalEditState) => {
    const { rooms } = this.state

    let errorMessages = []

    conflicts.forEach(c => {
      let message

      if (c.previewConflict) {
        message = `You attempted to make two new time slots that overlap. The overlap occurs on Day ${c.day} at the ${rooms.find(r => r.id == parseInt(c.room)).name} location.`
      } else {
        message = `You attempted to preview a slot which overlaps an existing slot. The overlap involves a previously existing slot on Day ${c.conference_day} at the ${rooms.find(r => r.id == c.room_id).name} location, between  ${c.start_time.split('T')[1].split('.')[0]} and ${c.end_time.split('T')[1].split('.')[0]}`
      }
       
      errorMessages.push(message)
    })

    errorMessages =  [...new Set(errorMessages)];
    this.setState({
      errorMessages,
      bulkTimeSlotModalEditState,
      bulkTimeSlotModalOpen: false,
    })
  }

  createTimeSlotPreviews = (previewSlots, bulkTimeSlotModalEditState) => {
    let { startTime, endTime } = this.state

    previewSlots.forEach(preview => {
      if (preview.startTime < startTime) {
        startTime = preview.startTime
      }
      if (preview.endTime > endTime) {
        endTime = preview.endTime
      }
    })

    let conflicts = this.findTimeSlotConflicts(previewSlots)

    if (conflicts.length > 0) {
      this.handleConflicts(conflicts, bulkTimeSlotModalEditState)
    } else {
      this.setState({
        previewSlots, 
        bulkTimeSlotModalEditState, 
        bulkTimeSlotModalOpen: false,
        dayViewing: parseInt(bulkTimeSlotModalEditState.day),
        startTime,
        endTime
      })
    }

  }

  requestBulkTimeSlotCreate = () => {
    const {bulkTimeSlotModalEditState, bulkPath} = this.state
    const {day, duration, rooms, startTimes} = bulkTimeSlotModalEditState

    // the API expects time strings to have a minutes declaration, this following code adds a minute decaration to each time in a string, if needed. 
    const formattedTimes = startTimes.replace(/\s/g, '').split(',').map(time => {
      if (time.split(':').length > 1) {
        return time
      } else {
        return time + ':00'
      }
    }).join(', ')

    postBulkTimeSlots(bulkPath, day, rooms, duration, formattedTimes)
      .then(response => response.json())
      .then(data => {
        const { errors } = data

        if (errors) {
          this.setState({ bulkErrorMessages: errors })
          return
        }

        this.setState({ 
          slots: data.slots, 
          previewSlots: [], 
          bulkTimeSlotModalEditState: null 
        }, () => {
          let hours = this.determineHours(this.state.slots)
          this.setState({...hours})
        })
      })
      .catch(err => console.log('Error: ', err))
  }

  componentDidMount() {
    let hours = this.determineHours(this.props.slots)
    const trackColors = palette("tol-rainbow", this.props.tracks.length)
    this.props.tracks.forEach((track, i) => {
      track.color = "#" + trackColors[i]
    })
    
    this.setState(Object.assign(this.state, this.props, hours))
  }

  showErrors = messages => {
    this.setState({ errorMessages: messages })
  }

  removeErrors = () => {
    this.setState({ errorMessages: [], bulkErrorMessages: [] })
  }

  render() {
    const {
      counts,
      dayViewing,
      startTime,
      endTime,
      sessions,
      unscheduledSessions,
      draggedSession,
      tracks,
      bulkTimeSlotModalOpen,
      bulkTimeSlotModalEditState,
      previewSlots,
      slots,
      rooms,
      sessionFormats,
      errorMessages,
      bulkErrorMessages,
    } = this.state

    const headers = rooms.map(room => (
      <div className="schedule_column_head" key={'column_head_' + room.name}>
        {room.name}
      </div>
    ))

    const headersMinWidth = (180 * rooms.length) + 'px'

    const bulkTimeSlotModal = bulkTimeSlotModalOpen && <BulkCreateModal 
      closeBulkTimeSlotModal={this.closeBulkTimeSlotModal}
      dayViewing={dayViewing}
      counts={counts}
      rooms={rooms}
      createTimeSlotPreviews={this.createTimeSlotPreviews}
      editState={bulkTimeSlotModalEditState}
      sessionFormats={sessionFormats}
    />

    return (
      <div className="schedule_grid">
        {errorMessages.length > 0 && (
          <Alert
            messages={errorMessages}
            onClose={this.removeErrors}
          />
        )}
        {bulkErrorMessages.length > 0 && (
          <Alert
            messages={bulkErrorMessages}
            onClose={this.removeErrors}
          />
        )}
        {bulkTimeSlotModal}
        <div className='nav_wrapper'>
          <Nav
            counts={counts}
            changeDayView={this.changeDayView}
            dayViewing={dayViewing}
            slots={slots}
          />
          <GenerateGridButton
            dayViewing={dayViewing}
            generateGridPath={this.props.bulk_path}
            openBulkTimeSlotModal={this.openBulkTimeSlotModal}
          />
        </div>
        <div className="grid_headers_wrapper" style={{'minWidth': headersMinWidth}}>{headers}</div>
        <div className="grid_container">
          {previewSlots.length > 0 && <BulkGenerateConfirm 
            cancelBulkPreview={this.cancelBulkPreview}
            openBulkTimeSlotModal={this.openBulkTimeSlotModal}
            requestBulkTimeSlotCreate={this.requestBulkTimeSlotCreate}
          />}
          <Ruler startTime={startTime} endTime={endTime} />
          <DayView
            dayViewing={dayViewing}
            startTime={startTime}
            endTime={endTime}
            ripTime={this.ripTime}
            changeDragged={this.changeDragged}
            draggedSession={draggedSession}
            sessions={sessions}
            tracks={tracks}
            previewSlots={previewSlots}
            rooms={rooms}
            slots={slots}
            handleMoveSessionResponse={this.handleMoveSessionResponse}
            unscheduledSessions={unscheduledSessions}
            sessionFormats={sessionFormats}
            showErrors={this.showErrors}
          />
          <UnscheduledArea
            unscheduledSessions={unscheduledSessions}
            sessions={sessions}
            changeDragged={this.changeDragged}
            draggedSession={draggedSession}
            tracks={tracks}
            handleMoveSessionResponse={this.handleMoveSessionResponse}
          />
        </div>
      </div>
    )
  }
}

Schedule.propTypes = {
  schedule: PropTypes.object,
  sessions: PropTypes.array,
  counts: PropTypes.object,
  unscheduledSessions: PropTypes.array,
  tracks: PropTypes.array
}

export default Schedule
