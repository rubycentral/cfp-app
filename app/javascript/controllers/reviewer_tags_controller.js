import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "icon", "form"]

  toggle() {
    this.displayTarget.classList.toggle('hidden')
    this.iconTarget.classList.toggle('hidden')
    this.formTarget.classList.toggle('hidden')
  }
}
