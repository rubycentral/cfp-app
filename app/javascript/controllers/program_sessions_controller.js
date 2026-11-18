import CfpDatatableController from './cfp_datatable_controller'

export default class extends CfpDatatableController {
  static targets = [...CfpDatatableController.targets, 'indicator']

  get options() {
    return {
      // The hidden last column holds the program/waitlist/declined group; name it so
      // filterBy does not depend on how many columns precede it (Track is optional).
      columnDefs: [{targets: -1, name: 'group'}],
      layout: {
        topStart: null,
        topEnd: () => this.createResetSortButton(),
        bottomStart: 'pageLength',
        bottomEnd: 'paging'
      }
    }
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

    this.dataTable.column('group:name').search(type).draw()
  }
}
