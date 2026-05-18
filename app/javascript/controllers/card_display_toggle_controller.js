import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['button']

  toggle() {
    this.element.classList.toggle('show-speakers')
    const showingSpeakers = this.element.classList.contains('show-speakers')
    this.buttonTarget.textContent = showingSpeakers ? 'Show Titles' : 'Show Speakers'
  }
}
