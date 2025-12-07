import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['table']

  connect() {
    this.dataTable = cfpDataTable(this.tableTarget, JSON.parse(this.tableTarget.dataset.cfpColumnTypes || '[]'), {
      stateSaveParams: () => {
        const rows = this.tableTarget.querySelectorAll('[data-proposal-id]')
        const uuids = Array.from(rows).map(row => row.dataset.proposalUuid)
        localStorage.proposal_uuid_table_order = JSON.stringify(uuids)
      },
      sDom: '<"top"i>Crt<"bottom"lp><"clear">'
    })

    this.tableTarget.querySelectorAll('input').forEach(el => el.classList.add('form-control'))
  }

  resetSort() {
    const settings = this.dataTable.settings()[0]
    settings.aaSorting = []
    settings.aiDisplay.sort((x, y) => x - y)
    settings.aiDisplayMaster.sort((x, y) => x - y)
    this.dataTable.draw()
  }
}
