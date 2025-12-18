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
        topEnd: () => this.createResetSortButton(),
        bottomStart: 'pageLength',
        bottomEnd: 'paging'
      }
    }
  }

  filterByStatus(event) {
    const statusSelect = this.tableElement.querySelector('select[name="filter_status"]')
    if (!statusSelect) return

    statusSelect.value = event.currentTarget.dataset.statusFilter
    statusSelect.dispatchEvent(new Event('change'))
  }
}
