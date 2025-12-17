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
      orderCellsTop: false,
      layout: {
        topStart: null,
        topEnd: () => this.createResetSortButton(),
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

          if (!cell) return

          // Clear cell content and prevent sort clicks on filter row
          cell.innerHTML = ''
          cell.addEventListener('click', (e) => e.stopPropagation())

          // Skip adding filter input for null columns
          if (type === null) return

          const input = document.createElement('input')
          input.type = 'text'
          input.className = 'form-control form-control-sm'
          input.placeholder = ''
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

  createResetSortButton() {
    const btn = document.createElement('button')
    btn.type = 'button'
    btn.className = 'btn btn-primary btn-sm'
    btn.textContent = 'Reset Sort Order'
    btn.addEventListener('click', () => this.resetSort())
    return btn
  }

  resetSort() {
    this.dataTable.order([]).draw()
  }
}
