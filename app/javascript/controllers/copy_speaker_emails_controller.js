import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  copy(e) {
    e.preventDefault()

    const emails = Array.from(document.querySelectorAll('#program-sessions tbody tr'))
      .map(row => JSON.parse(row.dataset.emails || '[]'))
      .flat()
      .join(', ')

    navigator.clipboard.writeText(emails).then(() => {
      this.showNotification()
    })
  }

  showNotification() {
    const flash = document.createElement('div')
    flash.className = 'container alert alert-dismissable alert-info'
    flash.innerHTML = `
      <button class="btn-close" data-bs-dismiss="alert"></button>
      <p class="text-center">emails copied to clipboard</p>
    `
    document.getElementById('flash').appendChild(flash)
  }
}
