import CfpDatatableController from './cfp_datatable_controller'

export default class extends CfpDatatableController {
  get options() {
    return {
      stateSaveParams: () => {
        const rows = this.tableElement.querySelectorAll('[data-proposal-id]')
        const uuids = Array.from(rows).map(row => row.dataset.proposalUuid)
        localStorage.proposal_uuid_table_order = JSON.stringify(uuids)
      },
      sDom: '<"top"i>Crt<"bottom"lp><"clear">'
    }
  }

  connect() {
    super.connect()
    this.tableElement.querySelectorAll('input').forEach(el => el.classList.add('form-control'))
  }

  resetSort() {
    const settings = this.dataTable.settings()[0]
    settings.aaSorting = []
    settings.aiDisplay.sort((x, y) => x - y)
    settings.aiDisplayMaster.sort((x, y) => x - y)
    this.dataTable.draw()
  }
}
