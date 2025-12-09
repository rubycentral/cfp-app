import CfpDatatableController from './cfp_datatable_controller'

export default class extends CfpDatatableController {
  get options() {
    return {
      stateSaveParams: () => {
        const rows = this.tableElement.querySelectorAll('[data-proposal-id]')
        const uuids = Array.from(rows).map(row => row.dataset.proposalUuid)
        localStorage.proposal_uuid_table_order = JSON.stringify(uuids)
      },
      layout: {
        topStart: 'info',
        topEnd: null,
        bottomStart: 'pageLength',
        bottomEnd: 'paging'
      }
    }
  }

  resetSort() {
    this.dataTable.order([]).draw()
  }
}
