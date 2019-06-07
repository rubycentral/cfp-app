import React, { Component } from "react"
import PropTypes from "prop-types"

class TimeSlotModal extends Component {
  constructor(props) {
    super(props)
    this.state = {
      sessionSelected: this.props.matchedSession 
      ? this.props.matchedSession.title
      : ''
    }
  }

  componentDidMount() {
    const { csrf, slot, matchedSession } = this.props
    console.log(slot, matchedSession)
  }

  changeSession(e) {
    this.setState({ sessionSelected: e.target.value })
  }

  render() {
    const { slot, matchedSession, unscheduledSessions, tracks } = this.props
    let sessionOptions
    if (matchedSession) {
      sessionOptions = [matchedSession, ...unscheduledSessions]
    } else {
      sessionOptions = [...unscheduledSessions]
    }
    sessionOptions = sessionOptions.map(session => (
      <option key={'session ' + session.title} value={session}>{session.title}</option>
    ))

    return (
      <div className='modal-container'>
        <div className='bulk-modal'>
          <div className='modal-body'>
            <label>
              Program Session
              <select
                className='full-width-input'
                value={this.state.sessionSelected}
                onChange={this.changeSession} >
                {sessionOptions}
              </select>
            </label>
          </div>
        </div>
      </div>
    )
  }
}

TimeSlotModal.propTypes = {

}

export default TimeSlotModal
