import { Controller } from 'stimulus'

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
    this.displayedIdValue = e.target.parentNode.getAttribute('displayedId')
  }

  displayedIdValueChanged() {
    this.hideExceptDisplayedId()
  }
}
