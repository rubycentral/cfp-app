import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  connect() {
    const modalElement = this.element.closest('.modal')
    if (!modalElement.classList.contains('show')) {
      const modal = Modal.getOrCreateInstance(modalElement)
      modal.show()
    }
  }
}
