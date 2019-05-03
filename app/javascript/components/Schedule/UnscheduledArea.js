import React from 'react'
import PropTypes from 'prop-types';

import ProgramSession from './ProgramSession';

class UnscheduledArea extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      searchInput: '',
      isHidden: false,
      opacity: 1
    }
  }

  handleChange = (e) => {
    this.setState({searchInput: e.target.value})
  }

  changeHiddenState = () => {
    this.setState({isHidden: !this.state.isHidden})
  }

  onDrag = (programSession) => {
    this.props.changeDragged(programSession);
  }

  render() {
    const {sessions, unscheduledSessions} = this.props;
    const {searchInput, isHidden} = this.state;

    let display = isHidden ? 'none' : '';

    let filteredSessions = unscheduledSessions.filter(session => {
      return session.title.toLowerCase().includes(searchInput.toLowerCase()) // also filter by track once that is determined by api
    })
    let unscheduledSessionCards = filteredSessions.map(session => (
      <ProgramSession key={session.id} session={session} onDrag={this.onDrag} />
    ));

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
            {unscheduledSessionCards}
          </div>
        </div>
      </div>
    )
  }
}

UnscheduledArea.propTypes = {
  unscheduledSessions: PropTypes.array,
  sessions: PropTypes.array,
  changeDragged: PropTypes.func
}

UnscheduledArea.defaultProps = {
  unscheduledSessions: [],
  sessions: []
}

export default UnscheduledArea