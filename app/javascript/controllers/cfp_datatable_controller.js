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
        const headerRows = api.table().header().querySelectorAll('tr')
        const filterRow = headerRows[0]
        const labelRow = headerRows[1]

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

          // Get column name from header row for input name attribute
          const headerText = labelRow?.children[index]?.textContent?.trim() || `column_${index}`
          const inputName = headerText.toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '')

          if (type === 'select') {
            // Create dropdown populated with unique column values
            const select = document.createElement('select')
            select.className = 'form-select form-select-sm'
            select.name = `filter_${inputName}`
            select.innerHTML = '<option value=""></option>'

            // Collect unique values (use data-search attribute if available, otherwise text content)
            const uniqueValues = new Map()
            column.nodes().each(function(node) {
              const searchValue = node.dataset.search || node.textContent.trim()
              if (searchValue && !uniqueValues.has(searchValue)) {
                uniqueValues.set(searchValue, node.textContent.trim())
              }
            })

            // Sort and add options
            Array.from(uniqueValues.entries()).sort((a, b) => a[1].localeCompare(b[1])).forEach(([value, label]) => {
              const option = document.createElement('option')
              option.value = value
              option.textContent = label
              select.appendChild(option)
            })

            cell.appendChild(select)

            select.addEventListener('change', () => {
              const val = select.value
              column.search(val ? `^${val.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$` : '', true, false).draw()
            })
          } else {
            // Create text input for other column types
            const input = document.createElement('input')
            input.type = 'text'
            input.className = 'form-control form-control-sm'
            input.name = `filter_${inputName}`
            input.placeholder = headerText
            cell.appendChild(input)

            input.addEventListener('keyup', () => {
              if (column.search() !== input.value) {
                column.search(input.value).draw()
              }
            })

            // Prevent sorting when clicking on input
            input.addEventListener('click', (e) => e.stopPropagation())
          }
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
