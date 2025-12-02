import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const $modal = $(this.element).closest('.modal')
    window.Schedule.TimeSlots.initDialog($modal)
    // Only show if not already visible
    if (!$modal.hasClass('in')) {
      $modal.modal('show')
    }
  }
}
