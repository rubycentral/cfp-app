import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    timeSlotId: String
  }

  connect() {
    const timeSlot = document.getElementById(`time_slot_${this.timeSlotIdValue}`)
    if (!timeSlot) {
      this.element.remove()
      return
    }

    const draggableSession = timeSlot.querySelector('.draggable-session-card')

    const gridElement = timeSlot.closest('[data-controller~="schedule-grid"]')
    if (gridElement) {
      const controller = this.application.getControllerForElementAndIdentifier(gridElement, 'schedule-grid')
      if (controller) controller.refreshTimeSlot(timeSlot)
    }

    const sessionsElement = document.querySelector('[data-controller~="draggable-sessions"]')
    if (sessionsElement && draggableSession) {
      const sessionsController = this.application.getControllerForElementAndIdentifier(sessionsElement, 'draggable-sessions')
      if (sessionsController) sessionsController.initDraggableSession(draggableSession)
    }

    this.element.remove()
  }
}
