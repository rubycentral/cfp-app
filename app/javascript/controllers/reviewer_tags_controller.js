import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "icon", "form"]

  toggle() {
    $(this.displayTarget).toggle()
    $(this.iconTarget).toggle()
    $(this.formTarget).slideToggle()
  }
}
