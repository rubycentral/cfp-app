import { Turbo } from "@hotwired/turbo-rails"
import DataTable from 'datatables.net-bs5'

// Custom Turbo Stream action: datatable-add
// Adds a row to a DataTable
// Usage: <turbo-stream action="datatable-add" target="table-id"><template><tr>...</tr></template></turbo-stream>
Turbo.StreamActions["datatable-add"] = function() {
  const tableElement = document.getElementById(this.target)
  if (!tableElement || !DataTable.isDataTable(tableElement)) return

  const table = new DataTable(tableElement)
  const template = this.templateContent.querySelector('tr')
  if (template) {
    table.row.add(template).draw()
  }
}

// Custom Turbo Stream action: datatable-remove
// Removes a row from a DataTable
// Usage: <turbo-stream action="datatable-remove" target="table-id" row-id="123"></turbo-stream>
Turbo.StreamActions["datatable-remove"] = function() {
  const tableElement = document.getElementById(this.target)
  if (!tableElement || !DataTable.isDataTable(tableElement)) return

  const rowId = this.getAttribute('row-id')
  const rowElement = tableElement.querySelector(`#time_slot_${rowId}`)
  if (!rowElement) return

  const table = new DataTable(tableElement)
  table.row(rowElement).remove().draw()
}

// Custom Turbo Stream action: datatable-update
// Updates a row in a DataTable
// Usage: <turbo-stream action="datatable-update" target="table-id" row-id="123"><template><tr>...</tr></template></turbo-stream>
Turbo.StreamActions["datatable-update"] = function() {
  const tableElement = document.getElementById(this.target)
  if (!tableElement || !DataTable.isDataTable(tableElement)) return

  const rowId = this.getAttribute('row-id')
  const existingRow = tableElement.querySelector(`#time_slot_${rowId}`)
  if (!existingRow) return

  const table = new DataTable(tableElement)
  const newRow = this.templateContent.querySelector('tr')
  if (newRow) {
    // Update each cell
    Array.from(newRow.cells).forEach((cell, i) => {
      if (existingRow.cells[i]) {
        existingRow.cells[i].innerHTML = cell.innerHTML
      }
    })
    table.row(existingRow).invalidate().draw()
  }
}
