import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  connect() {
    const modalElement = this.element.closest('.modal')
    const $dialog = $(this.element)

    // Initialize the bulk dialog - sync session format with duration
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

    if (!modalElement.classList.contains('show')) {
      const modal = Modal.getOrCreateInstance(modalElement)
      modal.show()
    }
  }
}
