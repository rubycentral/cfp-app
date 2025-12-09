import { Controller } from '@hotwired/stimulus'
import DataTable from 'datatables.net-bs5'

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
    // Skip if already initialized (prevents Turbo cache issues)
    if (DataTable.isDataTable(this.tableElement)) {
      this.dataTable = new DataTable(this.tableElement)
      return
    }

    const columnTypes = this.columnTypes

    const defaultOptions = {
      paging: false,
      stateSave: true,
      layout: {
        topStart: null,
        topEnd: null,
        bottomStart: 'info',
        bottomEnd: null
      },
      initComplete: function() {
        const api = this.api()
        const filterRow = api.table().header().querySelectorAll('tr')[0]

        api.columns().every(function(index) {
          const column = this
          const cell = filterRow.children[index]
          const type = columnTypes[index]

          if (!cell || type === null) return

          const input = document.createElement('input')
          input.type = 'text'
          input.className = 'form-control form-control-sm'
          input.placeholder = ''
          cell.innerHTML = ''
          cell.appendChild(input)

          input.addEventListener('keyup', () => {
            if (column.search() !== input.value) {
              column.search(input.value).draw()
            }
          })

          // Prevent sorting when clicking on input
          input.addEventListener('click', (e) => e.stopPropagation())
        })
      }
    }

    this.dataTable = new DataTable(this.tableElement, {...defaultOptions, ...this.options})
  }
}
