import { Controller } from 'stimulus'
import moment from 'moment'
import palette from 'palette'
import _ from 'lodash'

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
    const $columns = $(this.element).find('.room-column')
    if ($columns.length === 0) return

    const lineWidth = $columns.length * $columns.width()
    const styleId = 'schedule-grid-style'

    // Remove existing style if present
    $(`#${styleId}`).remove()

    $(`<style id="${styleId}">.schedule-grid .ruler li:after { width: ${lineWidth}px; }</style>`).appendTo('head')
  }

  updateDayRange() {
    const times = _.flatten(
      this.timeSlotTargets.map(slot => {
        const starts = parseInt(slot.dataset.starts)
        const duration = parseInt(slot.dataset.duration)
        return [starts, starts + duration]
      })
    )

    if (times.length > 0) {
      this.dayStartValue = Math.min(this.dayStartValue, _.min(times))
      this.dayEndValue = Math.max(this.dayEndValue, _.max(times))
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

    if (!$slot.hasClass('preview')) {
      $slot.off('click').on('click', (e) => this.onTimeSlotClick(e, slot))
    }

    // Setup droppable
    $slot.droppable({
      accept: '.draggable-session-card',
      hoverClass: 'draggable-hover',
      drop: (event, ui) => this.handleDrop(event, ui, slot)
    })
  }

  handleDrop(event, ui, slot) {
    const $sessionCard = $(ui.draggable)
    const $slot = $(slot)

    $sessionCard.detach().removeAttr('style').appendTo(slot)
    this.assignSizeClass($sessionCard, $slot)
    this.assignTrackColor($sessionCard)

    if ($sessionCard.data('scheduled')) {
      if (window.Schedule && window.Schedule.Drag) {
        window.Schedule.Drag.unschedule($sessionCard)
      }
    } else {
      $sessionCard.data('scheduled', true)
    }

    this.updateTimeSlot($slot, $sessionCard)

    $sessionCard.attr({
      'data-toggle': null,
      'data-target': null,
    })

    if (window.Schedule && window.Schedule.Drag) {
      $sessionCard.off('click', window.Schedule.Drag.showProgramSession)
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
      $ruler.append('<li>' + m.minutes(this.stepValue).format('hh:mma') + '</li>')
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
        $('.unscheduled-sessions-toggle .badge').text(
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

    $.ajax({ url: url })
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
