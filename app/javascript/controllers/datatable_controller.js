import { Controller } from "@hotwired/stimulus"
import DataTable from 'datatables.net-bs5'

export default class extends Controller {
  static values = {
    action: String,
    rowId: String,
    rowData: Array
  }

  connect() {
    const tableElement = document.querySelector('#organizer-time-slots.datatable')
    if (!tableElement || !DataTable.isDataTable(tableElement)) {
      this.element.remove()
      return
    }

    const table = new DataTable(tableElement)

    switch(this.actionValue) {
      case 'add':
        const template = this.element.querySelector('template')
        if (template) {
          const tempDiv = document.createElement('div')
          tempDiv.innerHTML = template.innerHTML
          const row = tempDiv.querySelector('tr')
          if (row) {
            table.row.add(row).draw()
          }
        }
        break
      case 'update':
        const existingRow = document.querySelector(`table#organizer-time-slots #time_slot_${this.rowIdValue}`)
        if (existingRow && this.rowDataValue) {
          const dtRow = table.row(existingRow)
          const data = this.rowDataValue
          // Update each cell in the row
          data.forEach((cellData, i) => {
            existingRow.cells[i].innerHTML = cellData
          })
          dtRow.invalidate().draw()
        }
        break
      case 'delete':
        const deleteRow = document.querySelector(`table#organizer-time-slots #time_slot_${this.rowIdValue}`)
        if (deleteRow) {
          table.row(deleteRow).remove().draw()
        }
        break
    }

    this.element.remove()
  }
}
