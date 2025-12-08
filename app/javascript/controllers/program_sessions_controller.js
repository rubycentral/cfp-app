import CfpDatatableController from './cfp_datatable_controller'

export default class extends CfpDatatableController {
  static targets = [...CfpDatatableController.targets, 'indicator']

  get options() {
    return {sDom: '<"top">Crt<"bottom"lp><"clear">'}
  }

  connect() {
    super.connect()
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
