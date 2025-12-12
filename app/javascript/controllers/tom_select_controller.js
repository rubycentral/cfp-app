import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

export default class extends Controller {
  static targets = ['input']
  static values = {
    sortable: { type: Boolean, default: false },
    create: { type: Boolean, default: false },
    options: { type: Array, default: [] },
    delimiter: { type: String, default: '' },
    labelClass: { type: String, default: '' }
  }

  get inputElement() {
    return this.hasInputTarget ? this.inputTarget : this.element
  }

  connect() {
    const plugins = ['remove_button']
    if (this.sortableValue) {
      plugins.push('drag_drop')
    }

    const options = { plugins }

    if (this.createValue) {
      options.persist = false
      options.create = (input) => ({ value: input, text: input })
    }

    if (this.delimiterValue) {
      options.delimiter = this.delimiterValue
      options.persist = false
      options.create = (input) => ({ value: input, text: input, item: input })
    }

    if (this.optionsValue.length > 0) {
      const items = this.optionsValue.map(x => ({ item: x }))
      options.options = items
      options.valueField = 'item'
      options.labelField = 'item'
      options.searchField = 'item'
    }

    if (this.labelClassValue) {
      options.render = {
        item: (data, escape) => '<div class="' + this.labelClassValue + '" style="margin-right: 4px;">' + escape(data.text) + '</div>'
      }
    }

    this.tomSelect = new TomSelect(this.inputElement, options)
  }

  disconnect() {
    if (this.tomSelect) {
      this.tomSelect.destroy()
    }
  }
}
