import React from "react"
import PropTypes from "prop-types"

class ProgramSession extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      opacity: 1
    }
  }

  drag = (session) => {
    this.props.onDrag(session)
    this.setState({opacity: .5})
  }

  dragEnd = e => {
    e.preventDefault()
    this.setState({ opacity: 1})
  }
  
  render() {
    const {session, tracks} = this.props;
    const {opacity} = this.state;

    const sessionTrack = tracks.find(track => track.id === session.track_id)

    const bkgColor = sessionTrack ? sessionTrack.color : '#fff'
    const trackName = sessionTrack ? sessionTrack.name : ''

    return(
      <div className='program_session_card' draggable={true} onDragStart={() => this.drag(session)} onDragEnd={(e) => this.dragEnd(e)}style={{'opacity': opacity}}>
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