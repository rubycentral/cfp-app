import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  submitEnd(event) {
    if (event.detail.success) {
      $(this.modalTarget).modal('hide')
    }
  }
}
