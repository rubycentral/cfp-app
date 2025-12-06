import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input']
  static values = {options: Array}

  connect() {
    const items = this.optionsValue.map(x => ({item: x}))

    new TomSelect(this.inputTarget, {
      delimiter: ',',
      persist: false,
      plugins: ['remove_button'],
      options: items,
      valueField: 'item',
      labelField: 'item',
      searchField: 'item',
      create: input => ({value: input, text: input, item: input})
    })
  }
}
