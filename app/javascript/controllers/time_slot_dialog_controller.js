import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  connect() {
    const modalElement = this.element.closest('.modal')
    window.Schedule.TimeSlots.initDialog($(modalElement))
    // Only show if not already visible
    if (!modalElement.classList.contains('show')) {
      const modal = Modal.getOrCreateInstance(modalElement)
      modal.show()
    }
  }
}
