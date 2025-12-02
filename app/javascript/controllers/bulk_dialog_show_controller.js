import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const $modal = $('#bulk-time-slot-create-dialog')

    // Re-initialize the dialog form handlers
    const $dialog = $modal.find('.modal-dialog')
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

    $modal.modal('show')
    this.element.remove()
  }
}
