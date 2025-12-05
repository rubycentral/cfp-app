import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['select']

  connect() {
    // Use jQuery's ready to ensure this runs after all other $(document).ready
    // handlers have been registered AND executed. This replicates the timing
    // of the old track.js which ran after sessions.js.
    // We use a nested setTimeout to ensure we run after jQuery's ready queue.
    $(() => {
      setTimeout(() => {
        this.filter()
      }, 0)
    })
  }

  filter() {
    const dataTable = $('table.datatable').DataTable()
    const track = this.selectTarget.options[this.selectTarget.selectedIndex].text

    // Replicate old track.js behavior: clear all column searches first
    dataTable.search('').columns().search('').draw()

    if (track !== 'All') {
      const trackColumn = dataTable.column(':contains(Track)')
      trackColumn.search(track).draw()
    }
  }
}
