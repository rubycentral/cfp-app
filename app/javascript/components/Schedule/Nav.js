import React from "react"
import PropTypes from "prop-types"
class Nav extends React.Component {
  render() {
    const { changeDayView, counts, dayViewing } = this.props;
    const navTabs = Object.keys(counts).map(dayNumber => {
      return <li 
        onClick={() => changeDayView(parseInt(dayNumber))}
        key={'day-tab ' + dayNumber}
        className={dayNumber === dayViewing.toString() ? 'active' : ''}
      > 
        <span>Day {dayNumber}</span> 
        <span className='badge'>{counts[dayNumber].scheduled}/{counts[dayNumber].total} </span>  
      </li>
    })

    return (
      <ul className='schedule_nav'>
        {navTabs}
      </ul>
    )
  };
}

export default Nav
