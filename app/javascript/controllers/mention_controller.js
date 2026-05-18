import { Controller } from '@hotwired/stimulus'
import Tribute from 'tributejs'

export default class extends Controller {
  connect() {
    const mentionNames = JSON.parse(this.element.dataset.mentionNames || '[]') || []
    const values = mentionNames.filter(Boolean).map(name => ({ key: name, value: name }))

    const tribute = new Tribute({
      trigger: '@',
      values: values,
      selectTemplate: item => '@' + item.original.value,
      menuItemTemplate: item => '@' + item.original.value,
      noMatchTemplate: '',
      lookup: 'key',
      fillAttr: 'value'
    })

    tribute.attach(this.element)
  }
}
