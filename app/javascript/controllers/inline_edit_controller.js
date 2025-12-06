import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['display', 'edit']

  show(e) {
    e.preventDefault()
    this.displayTarget.style.display = 'none'
    this.editTarget.style.display = 'block'
  }

  cancel(e) {
    e.preventDefault()
    this.editTarget.style.display = 'none'
    this.displayTarget.style.display = ''
  }
}
