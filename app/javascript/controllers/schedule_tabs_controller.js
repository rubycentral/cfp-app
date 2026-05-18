import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['tab', 'panel']
  static values = {
    activeDay: { type: Number, default: 1 }
  }

  connect() {
    this.showDay(this.activeDayValue)
  }

  switchDay(event) {
    event.preventDefault()
    const day = parseInt(event.currentTarget.dataset.day)
    this.showDay(day)
  }

  showDay(day) {
    this.activeDayValue = day

    this.tabTargets.forEach(tab => {
      const tabDay = parseInt(tab.dataset.day)
      tab.classList.toggle('active', tabDay === day)
    })

    this.panelTargets.forEach(panel => {
      const panelDay = parseInt(panel.dataset.day)
      const isActive = panelDay === day
      panel.classList.toggle('active', isActive)
      panel.style.display = isActive ? 'block' : 'none'
    })
  }
}
