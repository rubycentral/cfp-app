import { Controller } from '@hotwired/stimulus'
import cfpDataTable from '../utils/cfp_datatable'

export default class extends Controller {
  static targets = ['table', 'indicator']

  connect() {
    this.dataTable = cfpDataTable(this.tableTarget, JSON.parse(this.tableTarget.dataset.cfpColumnTypes || '[]'), {
      sDom: '<"top">Crt<"bottom"lp><"clear">'
    })

    this.filterBy('program')
  }

  filter(e) {
    this.filterBy(e.currentTarget.id)
  }

  filterBy(type) {
    const tab = document.getElementById(type)
    const position = tab.offsetLeft
    const width = tab.offsetWidth

    this.indicatorTarget.style.transition = 'left 0.3s, width 0.3s'
    this.indicatorTarget.style.left = position + 'px'
    this.indicatorTarget.style.width = width + 'px'

    this.dataTable.column(8).search(type).draw()
  }
}
