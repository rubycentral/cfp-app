import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    message: String
  }

  connect() {
    $("#time-slot-new-dialog .errors").html(this.messageValue)
    this.element.remove()
  }
}
