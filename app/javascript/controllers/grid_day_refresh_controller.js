import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  static values = {
    day: Number,
    switchDay: Boolean
  }

  connect() {
    const gridElement = document.getElementById(`schedule_day_${this.dayValue}`)
    if (gridElement) {
      const controller = window.Stimulus.getControllerForElementAndIdentifier(gridElement, 'schedule-grid')
      if (controller) controller.refreshDay()
    }

    if (this.switchDayValue) {
      const tabsElement = document.querySelector('[data-controller~="schedule-tabs"]')
      if (tabsElement) {
        const tabsController = window.Stimulus.getControllerForElementAndIdentifier(tabsElement, 'schedule-tabs')
        if (tabsController) tabsController.showDay(this.dayValue)
      }
    }

    // Close the modal
    const modalElement = document.getElementById('bulk-time-slot-create-dialog')
    const modal = Modal.getInstance(modalElement)
    if (modal) modal.hide()

    this.element.remove()
  }
}
