import { Controller } from '@hotwired/stimulus'
import cfpDataTable from '../utils/cfp_datatable'

export default class extends Controller {
  static targets = ['table']

  get tableElement() {
    return this.hasTableTarget ? this.tableTarget : this.element
  }

  get columnTypes() {
    return JSON.parse(this.tableElement.dataset.cfpColumnTypes || '[]')
  }

  get options() {
    return {}
  }

  connect() {
    this.dataTable = cfpDataTable(this.tableElement, this.columnTypes, this.options)
  }
}
