import { Controller } from '@hotwired/stimulus'
import cfpDataTable from '../utils/cfp_datatable'

export default class extends Controller {
  connect() {
    cfpDataTable(this.element, JSON.parse(this.element.dataset.cfpColumnTypes || '[]'))
  }
}
