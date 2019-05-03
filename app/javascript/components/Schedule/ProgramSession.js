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
    const {session} = this.props;
    const {opacity} = this.state;

    // just now realizing this won't work. Must hit API to determine track names and colors based on ID.
    const tracks = {
      '1': '#781C81',
      '2': '#D92120',
      '3': '#83BA6D'
    }

    const bkgColor = session.track_id ? tracks[session.track_id.toString()] : '#fff'

    return(
      <div className='program_session_card' draggable={true} onDragStart={() => this.drag(session)} onDragEnd={(e) => this.dragEnd(e)}style={{'opacity': opacity}}>
        <div className='card_header' style={{'backgroundColor': bkgColor}}>{'track.name'}</div>
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
  onDrag: PropTypes.func
}