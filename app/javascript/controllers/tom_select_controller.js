import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

export default class extends Controller {
  static values = {
    sortable: { type: Boolean, default: false },
    create: { type: Boolean, default: false }
  }

  connect() {
    const options = {}

    if (this.sortableValue || this.createValue) {
      options.plugins = ['drag_drop']
    }

    if (this.createValue) {
      options.persist = false
      options.create = (input) => ({ value: input, text: input })
    }

    this.tomSelect = new TomSelect(this.element, options)
  }

  disconnect() {
    if (this.tomSelect) {
      this.tomSelect.destroy()
    }
  }
}
