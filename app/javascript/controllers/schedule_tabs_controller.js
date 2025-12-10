import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['tab', 'panel', 'badge']
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

    // Update tab active states
    this.tabTargets.forEach(tab => {
      const tabDay = parseInt(tab.dataset.day)
      if (tabDay === day) {
        tab.classList.add('active')
      } else {
        tab.classList.remove('active')
      }
    })

    // Update panel visibility
    this.panelTargets.forEach(panel => {
      const panelDay = parseInt(panel.dataset.day)
      if (panelDay === day) {
        panel.classList.add('active')
        panel.style.display = 'block'
      } else {
        panel.classList.remove('active')
        panel.style.display = 'none'
      }
    })
  }

  updateBadge(day, scheduled, total) {
    const badge = this.badgeTargets.find(b => parseInt(b.dataset.day) === day)
    if (badge) {
      badge.textContent = `${scheduled}/${total}`
    }
  }
}
