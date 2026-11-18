import CfpDatatableController from './cfp_datatable_controller'

export default class extends CfpDatatableController {
  get options() {
    return {order: [[0, 'asc'], [1, 'asc']]}
  }

  reloadTable(rows) {
    this.dataTable.clear()
    rows.forEach(row => this.dataTable.row.add(row))
    this.dataTable.draw()
  }

  addRow(row) {
    this.dataTable.row.add(row).draw()
  }
}
