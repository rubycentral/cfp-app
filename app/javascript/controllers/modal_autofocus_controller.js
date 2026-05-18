import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.element.addEventListener('shown.bs.modal', this.focusAutofocusElement.bind(this))
  }

  disconnect() {
    this.element.removeEventListener('shown.bs.modal', this.focusAutofocusElement.bind(this))
  }

  focusAutofocusElement() {
    const autofocusEl = this.element.querySelector('[autofocus]')
    if (autofocusEl) {
      autofocusEl.focus()
    }
  }
}
