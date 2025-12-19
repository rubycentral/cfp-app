import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['button']

  connect() {
    this.showingSpeakers = false
    this.updateTooltips()
  }

  toggle() {
    this.showingSpeakers = !this.showingSpeakers
    this.element.classList.toggle('show-speakers', this.showingSpeakers)
    this.buttonTarget.textContent = this.showingSpeakers ? 'Show Titles' : 'Show Speakers'
    this.updateTooltips()
  }

  updateTooltips() {
    const cards = this.element.querySelectorAll('.draggable-session-card')
    cards.forEach(card => {
      card.title = this.showingSpeakers ? card.dataset.title : card.dataset.speakers
    })
  }
}
