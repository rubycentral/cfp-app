import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    if (localStorage.proposal_uuid_table_order !== undefined) {
      const proposalUuids = JSON.parse(localStorage.proposal_uuid_table_order)
      const currentIndex = proposalUuids.indexOf(this.element.dataset.proposalUuid)
      if (currentIndex + 1 < proposalUuids.length) {
        const nextUuid = proposalUuids[currentIndex + 1]
        this.element.href = this.element.href.replace('PLACEHOLDER', nextUuid)
      } else {
        this.element.remove()
      }
    } else {
      this.element.remove()
    }
  }
}
