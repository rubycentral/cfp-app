import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.setupPopovers()
  }

  change(e) {
    const select = e.target
    const selectType = select.dataset.selectType
    const id = select.value
    const url = select.dataset.targetPath
    const container = select.closest('td, span, div')

    this.removePopover(selectType)

    const params = selectType === 'track' ? {track_id: id} : {session_format_id: id}

    fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: new URLSearchParams(params)
    })
      .then(response => response.text())
      .then(html => {
        container.innerHTML = html
        this.updateProposalSelect(html, selectType, id)
        this.setupPopovers()
      })
  }

  updateProposalSelect(html, selectType, newId) {
    const parser = new DOMParser()
    const doc = parser.parseFromString(html, 'text/html')
    const opt = doc.querySelector(`option[value='${newId}']`)?.textContent || ''

    const nameEl = document.getElementById(`${selectType}-name`)
    if (nameEl) nameEl.innerHTML = opt

    const editWrapper = document.getElementById(`edit-${selectType}-wrapper`)
    if (editWrapper) {
      editWrapper.style.display = 'none'
      const lastLabel = editWrapper.querySelectorAll('.control-label')
      if (lastLabel.length > 0) lastLabel[lastLabel.length - 1].remove()
    }

    const currentEl = document.getElementById(`current-${selectType}`)
    if (currentEl) currentEl.style.display = ''
  }

  setupPopovers() {
    document.querySelectorAll('[data-bs-toggle="popover"]').forEach(el => {
      new bootstrap.Popover(el, {container: 'body'})
    })
  }

  removePopover(selectType) {
    const wrapper = document.getElementById(`edit-${selectType}-wrapper`)
    if (wrapper) {
      const select = wrapper.querySelector('select')
      if (select) {
        const targetId = select.getAttribute('aria-describedby')
        if (targetId) document.getElementById(targetId)?.remove()
      }
    }
  }
}
