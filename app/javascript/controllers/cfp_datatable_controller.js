import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    cfpDataTable(this.element, JSON.parse(this.element.dataset.cfpColumnTypes || '[]'))
  }
}
