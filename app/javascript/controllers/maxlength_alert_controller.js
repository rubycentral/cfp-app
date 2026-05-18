import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  check() {
    const maxlength = this.element.getAttribute('maxlength')
    if (this.element.value.length > maxlength) {
      alert('Character limit of ' + maxlength + ' has been exceeded')
    }
  }
}
