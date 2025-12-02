import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    timeSlotId: String
  }

  connect() {
    const $timeSlot = $(`#time_slot_${this.timeSlotIdValue}`)
    const $draggableSession = $timeSlot.find('.draggable-session-card')

    const gridElement = $timeSlot.closest('[data-controller~="schedule-grid"]')[0]
    if (gridElement) {
      const controller = window.Stimulus.getControllerForElementAndIdentifier(gridElement, 'schedule-grid')
      if (controller) controller.refreshTimeSlot($timeSlot[0])
    }

    const sessionsElement = document.querySelector('[data-controller~="draggable-sessions"]')
    if (sessionsElement && $draggableSession.length) {
      const sessionsController = window.Stimulus.getControllerForElementAndIdentifier(sessionsElement, 'draggable-sessions')
      if (sessionsController) sessionsController.initDraggableSession($draggableSession[0])
    }

    this.element.remove()
  }
}
