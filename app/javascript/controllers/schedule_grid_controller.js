import { Controller } from 'stimulus'
import { Modal } from 'bootstrap'

// These are available globally from the Rails asset pipeline
const moment = window.moment
const palette = window.palette

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
    // Cleanup event listeners if needed
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
    const $slot = $(slot)
    const duration = parseInt(slot.dataset.duration)
    const starts = parseInt(slot.dataset.starts)

    $slot.css({
      height: (duration * this.verticalScaleValue) + 'px',
      top: ((starts - this.dayStartValue) * this.verticalScaleValue) + 'px'
    })

    const $cards = $slot.find('.draggable-session-card, .custom-session-card')
    this.assignSizeClass($cards, $slot)
    this.assignTrackColor($cards)

    // Setup draggable for session cards in this slot
    const sessionCards = slot.querySelectorAll('.draggable-session-card')
    sessionCards.forEach(card => this.makeDraggable(card))

    if (!$slot.hasClass('preview')) {
      $slot.off('click').on('click', (e) => this.onTimeSlotClick(e, slot))
    }

    // Setup native HTML5 drag and drop
    this.setupDropZone(slot)
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
    const $sessionCard = $(sessionCard)
    const $slot = $(slot)

    // Check if slot already has a session - if so, move it to unscheduled
    const existingCard = slot.querySelector('.draggable-session-card')
    if (existingCard && existingCard !== sessionCard) {
      this.moveToUnscheduled(existingCard)
    }

    $sessionCard.detach().removeAttr('style').appendTo(slot)
    $sessionCard.css({
      position: 'absolute',
      top: 0,
      left: 0,
      height: '100%',
      width: '100%',
      margin: 0
    })
    this.assignSizeClass($sessionCard, $slot)
    this.assignTrackColor($sessionCard)

    if ($sessionCard.data('scheduled')) {
      this.unscheduleSession($sessionCard)
    } else {
      $sessionCard.data('scheduled', true)
    }

    this.updateTimeSlot($slot, $sessionCard)

    $sessionCard.attr({
      'data-toggle': null,
      'data-target': null,
    })

    $sessionCard.off('click', this.showProgramSession)
  }

  moveToUnscheduled(sessionCard) {
    const $sessionCard = $(sessionCard)
    const widget = document.querySelector('.unscheduled-sessions-widget')

    if (widget) {
      $sessionCard.detach().removeAttr('style').removeClass('small medium large').prependTo(widget)

      $sessionCard.data('scheduled', null)
      $sessionCard.attr({
        'data-scheduled': null,
        'data-toggle': 'modal',
        'data-target': '#program-session-show-dialog'
      })
    }
  }

  unscheduleSession($sessionCard) {
    const unschedulePath = $sessionCard.data('unscheduleTimeSlotPath')
    if (unschedulePath) {
      $.ajax({
        url: unschedulePath,
        method: 'patch',
        data: { time_slot: { program_session_id: '' } },
        success: (data) => {
          $('.header_wrapper .badge').text(
            data.unscheduled_count + '/' + data.total_count
          )
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
      'data-toggle': 'modal',
      'data-target': '#program-session-show-dialog'
    })
  }

  showProgramSession(e) {
    const $card = $(e.currentTarget)
    const url = $card.data('showPath')
    const scheduled = $card.data('scheduled')
    if (url && !scheduled) {
      fetch(url, {
        headers: {
          'Accept': 'text/vnd.turbo-stream.html, text/html',
          'Turbo-Frame': 'program-session-show-dialog'
        }
      }).then(response => response.text())
        .then(html => {
          const frame = document.getElementById('program-session-show-dialog').querySelector('turbo-frame')
          if (frame) {
            frame.innerHTML = html
          }
        })
    }
  }

  assignTrackColor($element) {
    const trackCss = $element.data('trackCss')
    if (!trackCss || !this.hasTracksCssValue) return

    const i = this.tracksCssValue.indexOf(trackCss)
    if (i >= 0 && this.trackColors[i]) {
      $element.find('.track').css({
        backgroundColor: '#' + this.trackColors[i],
        color: 'white'
      })
    }
  }

  assignSizeClass($sessionCard, $slot) {
    const slotHeight = $slot.height()

    $sessionCard.removeClass('small medium large')

    if (slotHeight < 70) {
      $sessionCard.addClass('small')
    } else if (slotHeight < 140) {
      $sessionCard.addClass('medium')
    } else {
      $sessionCard.addClass('large')
    }
  }

  initRuler(ruler) {
    const $ruler = $(ruler)
    const m = moment().startOf('day').minutes(this.dayStartValue - this.stepValue)

    $ruler.empty()
    for (let i = this.dayStartValue; i <= this.dayEndValue; i += this.stepValue) {
      $ruler.append('<li class="ruler_tick">' + m.minutes(this.stepValue).format('hh:mma') + '</li>')
    }
  }

  updateTimeSlot($timeSlot, $dragged_session) {
    const updatePath = $timeSlot.data('updatePath')
    if (!updatePath) return

    $.ajax({
      url: updatePath,
      method: 'patch',
      data: {
        time_slot: { program_session_id: $dragged_session.data('id') }
      },
      success: (data) => {
        $('.header_wrapper .badge').text(
          data.unscheduled_count + '/' + data.total_count
        )
        $('.total.time-slots .badge').each(function(i, badge) {
          const counts = data.day_counts[i + 1]
          $(badge).text(counts.scheduled + '/' + counts.total)
        })
      }
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
        window.Schedule.TimeSlots.initDialog($(dialog))
        const modal = Modal.getOrCreateInstance(dialog)
        modal.show()
      })
  }

  setupScrollHandlers() {
    this.gridScrollHandler = this.handleGridScroll.bind(this)
    this.windowScrollHandler = this.handleWindowScroll.bind(this)

    $(this.element).on('scroll', this.gridScrollHandler)
    $(window).on('scroll', this.windowScrollHandler)
  }

  teardownScrollHandlers() {
    $(this.element).off('scroll', this.gridScrollHandler)
    $(window).off('scroll', this.windowScrollHandler)
  }

  handleGridScroll(e) {
    this.columnHeaderTargets.forEach(header => {
      const positionX = $(header).parent().position().left
      $(header).css({ left: positionX })
    })
  }

  handleWindowScroll() {
    const scroll = $(window).scrollTop()
    const $headers = $(this.columnHeaderTargets)

    if (scroll >= 55) {
      $headers.css({ position: 'fixed', width: '180px', top: '130px', zIndex: '15' })
    } else {
      $headers.css({ position: 'static', width: '100%', zIndex: '10' })
    }
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
    const $dialog = $(dialog)
    const $format = $dialog.find('select.session-format')
    const $duration = $dialog.find('.time-slot-duration')

    $format.off('change').on('change', function(ev) {
      $duration.val($format.val())
    })

    $duration.off('keyup').on('keyup', function(ev) {
      if ($duration.is(':focus')) {
        $format.val('')
      }
    })
  }
}
