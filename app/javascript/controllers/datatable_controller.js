import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['row']
  static values = {
    action: String,
    rowId: String,
    rowData: Array
  }

  connect() {
    const table = $('#organizer-time-slots.datatable').dataTable()

    switch(this.actionValue) {
      case 'add':
        const template = this.element.querySelector('template')
        if (template) {
          const row = $(template.innerHTML).filter('tr')[0]
          if (row) {
            window.Schedule.TimeSlots.addRow(row)
          }
        }
        break
      case 'update':
        const row = $(`table#organizer-time-slots #time_slot_${this.rowIdValue}`)[0]
        if (row && this.rowDataValue) {
          const data = this.rowDataValue
          for (let i = 0; i < data.length; ++i) {
            table.fnUpdate(data[i], row, i)
          }
        }
        break
      case 'delete':
        const deleteRow = $(`table#organizer-time-slots #time_slot_${this.rowIdValue}`)[0]
        if (deleteRow) {
          table.fnDeleteRow(deleteRow)
        }
        break
    }

    this.element.remove()
  }
}
