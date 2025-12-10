import { Controller } from '@hotwired/stimulus'
import palette from 'google-palette'

export default class extends Controller {
  static targets = ['widget', 'session', 'toggle', 'badge', 'searchInput']
  static values = {
    tracksCss: Array
  }

  connect() {
    this.trackColors = []
    this.initTrackColors()
    this.initDraggableSessions()
    this.setupDropZone()
  }

  initTrackColors() {
    if (this.hasTracksCssValue) {
      this.trackColors = palette('tol-rainbow', this.tracksCssValue.length)
    }
  }

  initDraggableSessions() {
    this.sessionTargets.forEach(session => {
      this.initDraggableSession(session)
    })
  }

  initDraggableSession(session) {
    const trackCss = session.dataset.trackCss
    const i = this.tracksCssValue.indexOf(trackCss)

    if (i >= 0 && this.trackColors[i]) {
      const trackElement = session.querySelector('.track')
      if (trackElement) {
        trackElement.style.backgroundColor = '#' + this.trackColors[i]
      }
    }

    // Setup native HTML5 drag
    session.setAttribute('draggable', 'true')
    session.addEventListener('dragstart', this.handleDragStart.bind(this))
    session.addEventListener('dragend', this.handleDragEnd.bind(this))

    const scheduled = session.dataset.scheduled
    if (!scheduled) {
      session.addEventListener('click', this.handleSessionClick.bind(this))
    }
  }

  handleDragStart(e) {
    const session = e.currentTarget
    session.style.opacity = '0.4'

    // Set the session ID in the data transfer
    e.dataTransfer.effectAllowed = 'move'
    e.dataTransfer.setData('text/plain', session.dataset.id)
  }

  handleDragEnd(e) {
    const session = e.currentTarget
    session.style.opacity = '1'
  }

  handleSessionClick(e) {
    const session = e.currentTarget
    const url = session.dataset.showPath
    const scheduled = session.dataset.scheduled

    if (url && !scheduled) {
      fetch(url, {
        headers: {
          'Accept': 'text/html',
          'Turbo-Frame': 'program-session-show-dialog'
        }
      }).then(response => response.text())
        .then(html => {
          const frame = document.querySelector('#program-session-show-dialog turbo-frame')
          if (frame) {
            frame.innerHTML = html
          }
        })
    }
  }

  setupDropZone() {
    if (!this.hasWidgetTarget) return

    this.widgetTarget.addEventListener('dragover', this.handleDragOver.bind(this))
    this.widgetTarget.addEventListener('drop', this.handleDrop.bind(this))
  }

  handleDragOver(e) {
    if (e.preventDefault) {
      e.preventDefault()
    }
    e.dataTransfer.dropEffect = 'move'
    return false
  }

  handleDrop(e) {
    if (e.stopPropagation) {
      e.stopPropagation()
    }
    e.preventDefault()

    const sessionId = e.dataTransfer.getData('text/plain')
    const sessionCard = document.querySelector(`[data-id="${sessionId}"].draggable-session-card`)

    if (sessionCard) {
      // Remove inline styles and move to widget
      sessionCard.removeAttribute('style')
      sessionCard.classList.remove('small', 'medium', 'large')
      this.widgetTarget.prepend(sessionCard)

      if (sessionCard.dataset.scheduled) {
        this.unschedule(sessionCard)
      }
    }

    return false
  }

  unschedule(sessionCard) {
    const unschedulePath = sessionCard.dataset.unscheduleTimeSlotPath
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    if (unschedulePath) {
      fetch(unschedulePath, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-CSRF-Token': csrfToken
        },
        body: 'time_slot[program_session_id]='
      })
        .then(response => response.json())
        .then(data => {
          if (this.hasBadgeTarget) {
            this.badgeTarget.textContent = data.unscheduled_count + '/' + data.total_count
          }
          document.querySelectorAll('.total.time-slots .badge').forEach((badge, i) => {
            const counts = data.day_counts[i + 1]
            if (counts) badge.textContent = counts.scheduled + '/' + counts.total
          })
        })
    }

    delete sessionCard.dataset.scheduled
  }

  toggleWidget(e) {
    e.preventDefault()
    document.querySelectorAll('.unscheduled-sessions-widget, .search-sessions-wrapper').forEach(el => {
      el.classList.toggle('hidden')
    })
  }

  filterSessions(e) {
    const query = e.target.value.toLowerCase()
    const sessions = this.widgetTarget.querySelectorAll('.draggable-session-card')

    sessions.forEach(session => {
      const text = session.textContent.toLowerCase()
      if (text.indexOf(query) > -1) {
        session.classList.remove('hidden')
      } else {
        session.classList.add('hidden')
      }
    })
  }

  clearSearch(e) {
    e.preventDefault()
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = ''
      this.widgetTarget.querySelectorAll('.draggable-session-card').forEach(session => {
        session.classList.remove('hidden')
      })
    }
  }
}
