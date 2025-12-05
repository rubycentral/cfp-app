import { Controller } from 'stimulus'

// palette is available globally from the Rails asset pipeline
const palette = window.palette

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
      session.setAttribute('data-bs-toggle', 'modal')
      session.setAttribute('data-bs-target', '#program-session-show-dialog')
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
      $.ajax({ url: url })
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
      const $sessionCard = $(sessionCard)
      $sessionCard.detach().removeAttr('style').prependTo(this.widgetTarget)
      $sessionCard.removeClass('small medium large')

      if ($sessionCard.data('scheduled')) {
        this.unschedule($sessionCard)
      }
    }

    return false
  }

  unschedule($sessionCard) {
    const unschedulePath = $sessionCard.data('unscheduleTimeSlotPath')

    if (unschedulePath) {
      $.ajax({
        url: unschedulePath,
        method: 'patch',
        data: { time_slot: { program_session_id: '' } },
        success: (data) => {
          if (this.hasBadgeTarget) {
            this.badgeTarget.textContent = data.unscheduled_count + '/' + data.total_count
          }
          $('.total.time-slots .badge').each(function(i, badge) {
            const counts = data.day_counts[i + 1]
            $(badge).text(counts.scheduled + '/' + counts.total)
          })
        }
      })
    }

    $sessionCard.data('scheduled', null)
    $sessionCard.attr({
      'data-scheduled': null,
      'data-bs-toggle': 'modal',
      'data-bs-target': '#program-session-show-dialog'
    })
  }

  toggleWidget(e) {
    e.preventDefault()
    $('.unscheduled-sessions-widget, .search-sessions-wrapper').toggleClass('hidden')
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
