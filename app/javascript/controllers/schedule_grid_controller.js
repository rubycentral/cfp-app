import { Controller } from '@hotwired/stimulus'
import palette from 'google-palette'
import dayjs from 'dayjs'
import { turboStreamFetch } from '../helpers/turbo_fetch'

export default class extends Controller {
  static targets = ['ruler', 'timeSlot', 'columnHeader']
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
    this.updateDayRange()
    this.initGrid()
    this.setupScrollHandlers()
    this.initialized = true
  }

  disconnect() {
    this.teardownScrollHandlers()
  }

  timeSlotTargetConnected(slot) {
    // Re-initialize time slot when it's added or replaced (e.g., after Turbo Stream replace)
    // Skip during initial connect() - initGrid() handles those
    // Also skipped if already initialized (via data-initialized attribute)
    if (this.initialized) {
      this.initTimeSlot(slot)
    }
  }

  initTrackColors() {
    if (this.hasTracksCssValue) {
      this.trackColors = palette('tol-rainbow', this.tracksCssValue.length)
    }
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
    // Skip if already initialized
    if (slot.dataset.initialized) return
    slot.dataset.initialized = 'true'

    const duration = parseInt(slot.dataset.duration)
    const starts = parseInt(slot.dataset.starts)

    slot.style.height = (duration * this.verticalScaleValue) + 'px'
    slot.style.top = ((starts - this.dayStartValue) * this.verticalScaleValue) + 'px'

    const cards = slot.querySelectorAll('.draggable-session-card, .custom-session-card')
    cards.forEach(card => {
      this.assignSizeClass(card, slot)
      this.assignTrackColor(card)
    })

    this.setupDropZone(slot)
    if (!slot.classList.contains('preview')) {
      slot.addEventListener('click', (e) => this.onTimeSlotClick(e, slot))
    }

    // Setup draggable for session cards
    const sessionCards = slot.querySelectorAll('.draggable-session-card')
    sessionCards.forEach(card => this.makeDraggable(card))
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
    e.preventDefault()
    e.dataTransfer.dropEffect = 'move'
  }

  handleDragEnter(e) {
    const slot = e.currentTarget
    if (slot.classList.contains('time-slot')) {
      slot.classList.add('draggable-hover')
    }
  }

  handleDragLeave(e) {
    const slot = e.currentTarget
    if (!slot.contains(e.relatedTarget)) {
      slot.classList.remove('draggable-hover')
    }
  }

  handleNativeDrop(e) {
    e.stopPropagation()
    e.preventDefault()

    const slot = e.currentTarget
    slot.classList.remove('draggable-hover')

    const sessionId = e.dataTransfer.getData('text/plain')
    const sessionCard = document.querySelector(`[data-id="${sessionId}"].draggable-session-card`)

    if (sessionCard && slot.classList.contains('time-slot')) {
      this.handleDrop(sessionCard, slot)
    }
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
    this.highlightCard(sessionCard)

    if (sessionCard.dataset.scheduled) {
      this.unscheduleSession(sessionCard)
    } else {
      sessionCard.dataset.scheduled = 'true'
    }

    // Update the unschedule path to point to the new slot
    sessionCard.dataset.unscheduleTimeSlotPath = slot.dataset.updatePath

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

  highlightCard(card) {
    card.classList.remove('highlight')
    // Force reflow to restart animation
    void card.offsetWidth
    card.classList.add('highlight')
  }

  unscheduleSession(sessionCard) {
    const unschedulePath = sessionCard.dataset.unscheduleTimeSlotPath
    if (unschedulePath) {
      turboStreamFetch(unschedulePath, { body: 'time_slot[program_session_id]=' })
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
    let m = dayjs().startOf('day').add(this.dayStartValue - this.stepValue, 'minute')

    ruler.innerHTML = ''
    for (let i = this.dayStartValue; i <= this.dayEndValue; i += this.stepValue) {
      m = m.add(this.stepValue, 'minute')
      const li = document.createElement('li')
      li.className = 'ruler-tick'
      li.textContent = m.format('hh:mma')
      ruler.appendChild(li)
    }
  }

  updateTimeSlot(slot, draggedSession) {
    const updatePath = slot.dataset.updatePath
    if (!updatePath) return

    turboStreamFetch(updatePath, {
      body: `time_slot[program_session_id]=${draggedSession.dataset.id}`
    })
  }

  onTimeSlotClick(ev, slot) {
    ev.stopPropagation()

    const url = slot.dataset.editPath
    if (!url || url.length === 0) return

    const frame = document.getElementById('grid-modal-content')
    if (frame) {
      frame.src = url
    }
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
}
