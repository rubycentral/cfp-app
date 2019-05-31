import React, { Component } from "react"
import PropTypes from "prop-types"

class ProgramSession extends Component {
  constructor(props) {
    super(props)
  }

  drag = (session) => {
    this.props.onDrag(session)
  }

  dragEnd = e => {
    e.preventDefault()
  }
  
  render() {
    const {session, tracks} = this.props

    const sessionTrack = tracks.find(track => track.id === session.track_id)

    const bkgColor = sessionTrack ? sessionTrack.color : '#fff'
    const trackName = sessionTrack ? sessionTrack.name : ''

    return(
      <div className='program_session_card' draggable={true} onDragStart={() => this.drag(session)} onDragEnd={(e) => this.dragEnd(e)}>
        <div className='card_header' style={{'backgroundColor': bkgColor}}>{trackName}</div>
        <div className='card_body'>
          <p>{session.title}</p>
        </div>
      </div>
    )
  }
}

export default ProgramSession

ProgramSession.propTypes = {
  session: PropTypes.object,
  onDrag: PropTypes.func,
  tracks: PropTypes.array
}

ProgramSession.defaultProps = {tracks: []}
