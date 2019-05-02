import React from 'react'
import PropTypes from 'prop-types';

import Talk from './Talk';

class UnscheduledArea extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      searchInput: '',
      isHidden: false
    }
  }

  handleChange = (e) => {
    this.setState({searchInput: e.target.value})
  }

  changeHiddenState = () => {
    this.setState({isHidden: !this.state.isHidden})
  }

  render() {
    const {sessions, unscheduledSessions} = this.props;
    const {searchInput, isHidden} = this.state;

    let display = isHidden ? 'none' : '';

    let unscheduledTalks = unscheduledSessions.map(talk => <Talk key={talk.id} talk={talk} />)

    return (
      <div className='unscheduled_area'>
        <div className='header_wrapper' onClick={this.changeHiddenState}>
          <h3>Unscheduled Sessions</h3>
          <span className='badge'>{unscheduledSessions.length}/{sessions.length} </span> 
        </div>
        <div 
          className='unscheduled_sessions'
          style={{'display': display}} 
        >
          <div className='search-sessions-wrapper'>
            <label>Search:</label>
            <input 
              type='text' 
              value={searchInput}
              onChange={(e) => this.handleChange(e)}
            ></input>
          </div>
          <div>
            {unscheduledTalks}
          </div>
        </div>
      </div>
    )
  }
}

UnscheduledArea.propTypes = {
  unscheduledSessions: PropTypes.array,
  sessions: PropTypes.array
}

UnscheduledArea.defaultProps = {
  unscheduledSessions: [],
  sessions: []
}

export default UnscheduledArea