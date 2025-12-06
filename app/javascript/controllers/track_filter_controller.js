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
    this.updateByTrackVisibility()
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
