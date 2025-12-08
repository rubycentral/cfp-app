import { Controller } from '@hotwired/stimulus'
import { Popover } from 'bootstrap'

export default class extends Controller {
  static values = {
    container: {type: String, default: ''}
  }

  connect() {
    const options = {}
    if (this.containerValue) {
      options.container = this.containerValue
    }
    this.popover = new Popover(this.element, options)
  }

  disconnect() {
    if (this.popover) {
      this.popover.dispose()
    }
  }
}
