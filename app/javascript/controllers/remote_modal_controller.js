import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  static targets = ["modal", "content"]

  connect() {
    this.observer = new MutationObserver(() => {
      if (this.contentTarget.querySelector('[data-hide-modal]')) {
        const modal = Modal.getInstance(this.modalTarget)
        if (modal) modal.hide()
      }
    })
    this.observer.observe(this.contentTarget, {childList: true})
  }

  disconnect() {
    this.observer.disconnect()
  }

  open(event) {
    event.preventDefault()
    const url = event.currentTarget.href

    fetch(url, {
      headers: {
        'Accept': 'text/html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.text())
    .then(html => {
      this.contentTarget.innerHTML = html
      const modal = Modal.getOrCreateInstance(this.modalTarget)
      modal.show()
    })
  }
}
