import { Controller } from '@hotwired/stimulus'
import { Modal } from 'bootstrap'
import palette from 'google-palette'
import moment from 'moment'

export default class extends Controller {
  static targets = ['grid', 'ruler', 'timeSlot', 'columnHeader']
  static values = {
    dayStart: { type: Number, default: 60 * 9 },  // minutes
    dayEnd: { type: Number, default: 60 * 19 },
    step: { type: Number, default: 60 },
    verticalScale: { type: Number, default: 1.5 },
    tracksCss: Array
  }

  connect() {
    this.trackColors = []
    this.initTrackColors()
    this.addGridLineStyle()
    this.updateDayRange()
    this.initGrid()
    this.setupScrollHandlers()
  }

  disconnect() {
    this.teardownScrollHandlers()
  }

  initTrackColors() {
    if (this.hasTracksCssValue) {
      this.trackColors = palette('tol-rainbow', this.tracksCssValue.length)
    }
  }

  addGridLineStyle() {
    // No longer adding horizontal grid lines - using schedule_ruler without :after pseudo-element
  }

  updateDayRange() {
    const times = this.timeSlotTargets.flatMap(slot => {
      const starts = parseInt(slot.dataset.starts)
      const duration = parseInt(slot.dataset.duration)
      return [starts, starts + duration]
    })

    if (times.length > 0) {
      this.dayStartValue = Math.min(this.dayStartValue, ...times)
      this.dayEndValue = Math.max(this.dayEndValue, ...times)
    }
  }

  initGrid() {
    this.timeSlotTargets.forEach(slot => this.initTimeSlot(slot))
    this.rulerTargets.forEach(ruler => this.initRuler(ruler))
  }

  initTimeSlot(slot) {
    const duration = parseInt(slot.dataset.duration)
    const starts = parseInt(slot.dataset.starts)

    slot.style.height = (duration * this.verticalScaleValue) + 'px'
    slot.style.top = ((starts - this.dayStartValue) * this.verticalScaleValue) + 'px'

    const cards = slot.querySelectorAll('.draggable-session-card, .custom-session-card')
    cards.forEach(card => {
      this.assignSizeClass(card, slot)
      this.assignTrackColor(card)
    })

    // Setup draggable for session cards in this slot
    const sessionCards = slot.querySelectorAll('.draggable-session-card')
    sessionCards.forEach(card => this.makeDraggable(card))

    if (!slot.classList.contains('preview')) {
      // Remove old listener by cloning (simpler than tracking handlers)
      const newSlot = slot.cloneNode(true)
      slot.parentNode.replaceChild(newSlot, slot)
      newSlot.addEventListener('click', (e) => this.onTimeSlotClick(e, newSlot))
      this.setupDropZone(newSlot)
    } else {
      this.setupDropZone(slot)
    }
  }

  makeDraggable(sessionCard) {
    sessionCard.setAttribute('draggable', 'true')
    sessionCard.addEventListener('dragstart', (e) => {
      e.currentTarget.style.opacity = '0.4'
      e.dataTransfer.effectAllowed = 'move'
      e.dataTransfer.setData('text/plain', e.currentTarget.dataset.id)
    })
    sessionCard.addEventListener('dragend', (e) => {
      e.currentTarget.style.opacity = '1'
    })
  }

  setupDropZone(slot) {
    slot.addEventListener('dragover', this.handleDragOver.bind(this))
    slot.addEventListener('dragenter', this.handleDragEnter.bind(this))
    slot.addEventListener('dragleave', this.handleDragLeave.bind(this))
    slot.addEventListener('drop', this.handleNativeDrop.bind(this))
  }

  handleDragOver(e) {
    if (e.preventDefault) {
      e.preventDefault()
    }
    e.dataTransfer.dropEffect = 'move'
    return false
  }

  handleDragEnter(e) {
    const slot = e.currentTarget
    if (slot.classList.contains('time-slot')) {
      slot.classList.add('draggable-hover')
    }
  }

  handleDragLeave(e) {
    const slot = e.currentTarget
    if (e.target === slot) {
      slot.classList.remove('draggable-hover')
    }
  }

  handleNativeDrop(e) {
    if (e.stopPropagation) {
      e.stopPropagation()
    }
    e.preventDefault()

    const slot = e.currentTarget
    slot.classList.remove('draggable-hover')

    const sessionId = e.dataTransfer.getData('text/plain')
    const sessionCard = document.querySelector(`[data-id="${sessionId}"].draggable-session-card`)

    if (sessionCard && slot.classList.contains('time-slot')) {
      this.handleDrop(sessionCard, slot)
    }

    return false
  }

  handleDrop(sessionCard, slot) {
    // Check if slot already has a session - if so, move it to unscheduled
    const existingCard = slot.querySelector('.draggable-session-card')
    if (existingCard && existingCard !== sessionCard) {
      this.moveToUnscheduled(existingCard)
    }

    sessionCard.removeAttribute('style')
    slot.appendChild(sessionCard)
    Object.assign(sessionCard.style, {
      position: 'absolute',
      top: '0',
      left: '0',
      height: '100%',
      width: '100%',
      margin: '0'
    })
    this.assignSizeClass(sessionCard, slot)
    this.assignTrackColor(sessionCard)

    if (sessionCard.dataset.scheduled) {
      this.unscheduleSession(sessionCard)
    } else {
      sessionCard.dataset.scheduled = 'true'
    }

    this.updateTimeSlot(slot, sessionCard)
  }

  moveToUnscheduled(sessionCard) {
    const widget = document.querySelector('.unscheduled-sessions-widget')

    if (widget) {
      sessionCard.removeAttribute('style')
      sessionCard.classList.remove('small', 'medium', 'large')
      widget.prepend(sessionCard)
      delete sessionCard.dataset.scheduled
    }
  }

  unscheduleSession(sessionCard) {
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
          const headerBadge = document.querySelector('.header_wrapper .badge')
          if (headerBadge) {
            headerBadge.textContent = data.unscheduled_count + '/' + data.total_count
          }
          document.querySelectorAll('.total.time-slots .badge').forEach((badge, i) => {
            const counts = data.day_counts[i + 1]
            if (counts) badge.textContent = counts.scheduled + '/' + counts.total
          })
        })
    }

    delete sessionCard.dataset.scheduled
  }

  assignTrackColor(element) {
    const trackCss = element.dataset.trackCss
    if (!trackCss || !this.hasTracksCssValue) return

    const i = this.tracksCssValue.indexOf(trackCss)
    if (i >= 0 && this.trackColors[i]) {
      const trackEl = element.querySelector('.track')
      if (trackEl) {
        trackEl.style.backgroundColor = '#' + this.trackColors[i]
        trackEl.style.color = 'white'
      }
    }
  }

  assignSizeClass(sessionCard, slot) {
    const slotHeight = slot.offsetHeight

    sessionCard.classList.remove('small', 'medium', 'large')

    if (slotHeight < 70) {
      sessionCard.classList.add('small')
    } else if (slotHeight < 140) {
      sessionCard.classList.add('medium')
    } else {
      sessionCard.classList.add('large')
    }
  }

  initRuler(ruler) {
    const m = moment().startOf('day').minutes(this.dayStartValue - this.stepValue)

    ruler.innerHTML = ''
    for (let i = this.dayStartValue; i <= this.dayEndValue; i += this.stepValue) {
      const li = document.createElement('li')
      li.className = 'ruler_tick'
      li.textContent = m.minutes(this.stepValue).format('hh:mma')
      ruler.appendChild(li)
    }
  }

  updateTimeSlot(slot, draggedSession) {
    const updatePath = slot.dataset.updatePath
    if (!updatePath) return

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    fetch(updatePath, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': csrfToken
      },
      body: `time_slot[program_session_id]=${draggedSession.dataset.id}`
    })
      .then(response => response.json())
      .then(data => {
        const headerBadge = document.querySelector('.header_wrapper .badge')
        if (headerBadge) {
          headerBadge.textContent = data.unscheduled_count + '/' + data.total_count
        }
        document.querySelectorAll('.total.time-slots .badge').forEach((badge, i) => {
          const counts = data.day_counts[i + 1]
          if (counts) badge.textContent = counts.scheduled + '/' + counts.total
        })
      })
  }

  onTimeSlotClick(ev, slot) {
    const url = slot.dataset.editPath
    if (!url || url.length === 0) return

    fetch(url, {
      headers: {
        'Accept': 'text/vnd.turbo-stream.html, text/html',
        'Turbo-Frame': 'grid-time-slot-edit-dialog'
      }
    }).then(response => response.text())
      .then(html => {
        const dialog = document.getElementById('grid-time-slot-edit-dialog')
        dialog.innerHTML = html
        const modal = Modal.getOrCreateInstance(dialog)
        modal.show()
      })
  }

  setupScrollHandlers() {
    this.gridScrollHandler = this.handleGridScroll.bind(this)
    this.windowScrollHandler = this.handleWindowScroll.bind(this)

    this.element.addEventListener('scroll', this.gridScrollHandler)
    window.addEventListener('scroll', this.windowScrollHandler)
  }

  teardownScrollHandlers() {
    this.element.removeEventListener('scroll', this.gridScrollHandler)
    window.removeEventListener('scroll', this.windowScrollHandler)
  }

  handleGridScroll(e) {
    this.columnHeaderTargets.forEach(header => {
      const parent = header.parentElement
      const positionX = parent.offsetLeft - this.element.scrollLeft
      header.style.left = positionX + 'px'
    })
  }

  handleWindowScroll() {
    const scroll = window.scrollY

    this.columnHeaderTargets.forEach(header => {
      if (scroll >= 55) {
        Object.assign(header.style, { position: 'fixed', width: '240px', top: '130px', zIndex: '15' })
      } else {
        Object.assign(header.style, { position: 'static', width: '100%', zIndex: '10' })
      }
    })
  }

  // Public methods for external use
  refreshDay() {
    this.updateDayRange()
    this.initGrid()
  }

  refreshTimeSlot(slot) {
    this.initTimeSlot(slot)
  }

  initBulkDialog(dialog) {
    const formatSelect = dialog.querySelector('select.session-format')
    const durationInput = dialog.querySelector('.time-slot-duration')

    if (formatSelect && durationInput) {
      formatSelect.addEventListener('change', () => {
        durationInput.value = formatSelect.value
      })

      durationInput.addEventListener('keyup', () => {
        if (document.activeElement === durationInput) {
          formatSelect.value = ''
        }
      })
    }
  }
}
