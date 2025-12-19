import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['button']

  connect() {
    this.showingSpeakers = false
  }

  toggle() {
    this.showingSpeakers = !this.showingSpeakers
    this.element.classList.toggle('show-speakers', this.showingSpeakers)
    this.buttonTarget.textContent = this.showingSpeakers ? 'Show Titles' : 'Show Speakers'
  }
}
