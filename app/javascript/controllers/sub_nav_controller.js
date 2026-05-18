import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['hideable']
  static values = {
    displayedId: String,
  }

  connect() {
    this.hideExceptDisplayedId()
  }

  hideExceptDisplayedId() {
    this.hideableTargets.forEach(target => {
      if(target.id != this.displayedIdValue) {
        target.classList.add('hidden');
      } else {
        target.classList.remove('hidden')
      }
    })
  }

  updateDisplay(e) {
    e.preventDefault()
    document.querySelector('.selected')?.classList.remove('selected')
    e.target.classList.add('selected')
    this.displayedIdValue = e.target.dataset.displayedid
  }

  displayedIdValueChanged() {
    this.hideExceptDisplayedId()
  }
}
