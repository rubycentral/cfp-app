import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    message: String
  }

  connect() {
    const errorsEl = document.querySelector("#time-slot-new-dialog .errors")
    if (errorsEl) errorsEl.innerHTML = this.messageValue
    this.element.remove()
  }
}
