import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  connect() {
    this.element.addEventListener('turbo:frame-load', () => this.open())
  }

  open() {
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

    Modal.getOrCreateInstance(this.element).show()
  }
}
