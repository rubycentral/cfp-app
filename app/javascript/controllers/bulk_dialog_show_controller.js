import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  connect() {
    const modalElement = document.getElementById('bulk-time-slot-create-dialog')
    const dialog = modalElement.querySelector('.modal-dialog')
    const formatSelect = dialog.querySelector('select.session-format')
    const durationInput = dialog.querySelector('.time-slot-duration')

    if (formatSelect && durationInput) {
      // Clone and replace to remove old event listeners
      const newFormat = formatSelect.cloneNode(true)
      const newDuration = durationInput.cloneNode(true)
      formatSelect.parentNode.replaceChild(newFormat, formatSelect)
      durationInput.parentNode.replaceChild(newDuration, durationInput)

      newFormat.addEventListener('change', () => {
        newDuration.value = newFormat.value
      })

      newDuration.addEventListener('keyup', () => {
        if (document.activeElement === newDuration) {
          newFormat.value = ''
        }
      })
    }

    const modal = Modal.getOrCreateInstance(modalElement)
    modal.show()
    this.element.remove()
  }
}
