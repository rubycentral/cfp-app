import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const titleEl = document.getElementById('time_slot_title')
    const presenterEl = document.getElementById('time_slot_presenter')
    const descriptionEl = document.getElementById('time_slot_description')
    const sessionIdEl = document.getElementById('time_slot_program_session_id')
    const errorsEl = document.querySelector("#time-slot-new-dialog .errors")

    if (titleEl) titleEl.value = ''
    if (presenterEl) presenterEl.value = ''
    if (descriptionEl) descriptionEl.value = ''
    if (sessionIdEl) {
      sessionIdEl.value = ''
      sessionIdEl.dispatchEvent(new Event('change', { bubbles: true }))
    }
    if (errorsEl) errorsEl.innerHTML = ''

    this.element.remove()
  }
}
