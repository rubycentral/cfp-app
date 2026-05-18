import { Controller } from '@hotwired/stimulus'
import DataTable from 'datatables.net-bs5'

export default class extends Controller {
  static targets = ['select']

  connect() {
    // Wait for DataTable to be initialized, then apply filter
    setTimeout(() => {
      this.filter()
    }, 0)
    this.updateByTrackVisibility()
  }

  filter() {
    const tableElement = document.querySelector('table.datatable')
    if (!tableElement || !DataTable.isDataTable(tableElement)) return

    const dataTable = new DataTable(tableElement)
    const track = this.selectTarget.options[this.selectTarget.selectedIndex].text

    // Clear all column searches first
    dataTable.search('').columns().search('').draw()

    if (track !== 'All') {
      const trackColumn = dataTable.column(':contains(Track)')
      trackColumn.search(track).draw()
    }

    this.updateBadgeCounts()
  }

  updateBadgeCounts() {
    const trackId = this.selectTarget.value.trim()
    const eventSlug = this.element.dataset.event

    fetch(`/events/${eventSlug}/staff/program/proposals/session_counts?track_id=${trackId}`)
      .then(response => response.json())
      .then(data => {
        document.querySelector('.by-track.all-accepted .badge').textContent = data.all_accepted_proposals
        document.querySelector('.by-track.all-waitlisted .badge').textContent = data.all_waitlisted_proposals
        this.updateByTrackVisibility()
      })
  }

  updateByTrackVisibility() {
    const display = this.selectTarget.value === 'all' ? 'none' : 'block'
    document.querySelectorAll('.by-track').forEach(el => el.style.display = display)
  }
}
