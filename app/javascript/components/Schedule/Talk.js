import React from "react"
import PropTypes from "prop-types"

class Talk extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      opacity: 1
    }
  }

  drag = (talk) => {
    this.props.onDrag(talk)
    this.setState({opacity: .5})
  }

  dragEnd = e => {
    e.preventDefault()
    this.setState({ opacity: 1})
  }
  
  render() {
    const {talk} = this.props;
    const {opacity} = this.state;

    // just now realizing this won't work. Must hit API to determine track names and colors based on ID.
    const tracks = {
      '1': '#781C81',
      '2': '#D92120',
      '3': '#83BA6D'
    }

    const bkgColor = talk.track_id ? tracks[talk.track_id.toString()] : '#ff'

    return(
      <div className='talk_card' draggable={true} onDragStart={() => this.drag(talk)} onDragEnd={(e) => this.dragEnd(e)}style={{'opacity': opacity}}>
        <div className='card_header' style={{'backgroundColor': bkgColor}}>{'track.name'}</div>
        <div className='card_body'>
          <p>{talk.title}</p>
        </div>
      </div>
    )
  }
}

export default Talk

Talk.propTypes = {
  talk: PropTypes.object,
  onDrag: PropTypes.func
}