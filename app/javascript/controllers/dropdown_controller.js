import { Controller } from '@hotwired/stimulus'
import { Dropdown } from 'bootstrap'

export default class extends Controller {
  connect() {
    this.dropdown = new Dropdown(this.element)
  }

  toggle(event) {
    event.preventDefault()
    this.dropdown.toggle()
  }

  disconnect() {
    if (this.dropdown) {
      this.dropdown.dispose()
    }
  }
}
