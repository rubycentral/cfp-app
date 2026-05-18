import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['button', 'dropdown']

  connect() {
    this.dropdownTarget.style.display = 'none'
  }

  show(e) {
    e.preventDefault()
    this.dropdownTarget.style.display = 'block'
    this.buttonTarget.style.display = 'none'
  }

  hide(e) {
    e.preventDefault()
    this.dropdownTarget.style.display = 'none'
    this.buttonTarget.style.display = ''
  }
}
