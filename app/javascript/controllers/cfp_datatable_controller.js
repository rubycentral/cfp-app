import { Controller } from '@hotwired/stimulus'

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
    const $el = $(this.tableElement)

    // Skip if already initialized (prevents Turbo cache issues)
    if ($.fn.DataTable.isDataTable($el)) {
      this.dataTable = $el.DataTable()
      return
    }

    const columns = this.columnTypes.map(t => {
      if (t !== null) return {type: t}
    })

    const defaultOptions = {
      sPaginationType: 'bootstrap',
      bPaginate: false,
      bStateSave: true,
      sDom: '<"top">Crt<"bottom"ilp><"clear">'
    }

    const $table = $el.dataTable({...defaultOptions, ...this.options})
    $table.columnFilter({
      sPlaceHolder: 'head:before',
      aoColumns: columns
    })

    this.dataTable = $table.api()
  }
}
