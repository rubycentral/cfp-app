import { Controller } from '@hotwired/stimulus'
import cfpDataTable from '../utils/cfp_datatable'

export default class extends Controller {
  static targets = ['table']

  connect() {
    this.dataTable = cfpDataTable(this.tableTarget, ['number', 'date', 'date', 'text', 'text', 'text', 'text'], {
      aaSorting: [[0, 'asc'], [1, 'asc']]
    })
  }

  reloadTable(rows) {
    this.dataTable.clear()
    rows.forEach(row => this.dataTable.row.add($(row)))
    this.dataTable.draw()
  }

  addRow(row) {
    this.dataTable.row.add($(row)).draw()
  }
}
