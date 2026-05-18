import { Controller } from '@hotwired/stimulus'
import { Alert } from 'bootstrap'

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 5000 }
  }

  connect() {
    this.timeout = setTimeout(() => {
      const alert = Alert.getOrCreateInstance(this.element)
      alert.close()
    }, this.delayValue)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }
}
