import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  connect() {
    const modalElement = this.element.closest('.modal')
    const formatSelect = this.element.querySelector('select.session-format')
    const durationInput = this.element.querySelector('.time-slot-duration')

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

    if (!modalElement.classList.contains('show')) {
      const modal = Modal.getOrCreateInstance(modalElement)
      modal.show()
    }
  }
}
