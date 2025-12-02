import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const $modal = $(this.element).closest('.modal')
    if (!$modal.hasClass('in')) {
      $modal.modal('show')
    }
  }
}
