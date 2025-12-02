import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const $modal = $(this.element).closest('.modal')
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

    if (!$modal.hasClass('in')) {
      $modal.modal('show')
    }
  }
}
