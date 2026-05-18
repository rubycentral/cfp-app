import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  connect() {
    this.element.addEventListener('turbo:frame-load', () => this.onFrameLoad())
    document.addEventListener('turbo:submit-end', this.handleSubmitEnd)
    document.addEventListener('turbo:before-stream-render', this.handleStreamRender)
  }

  disconnect() {
    document.removeEventListener('turbo:submit-end', this.handleSubmitEnd)
    document.removeEventListener('turbo:before-stream-render', this.handleStreamRender)
  }

  handleStreamRender = (event) => {
    const stream = event.target
    if (stream.action === 'replace' && stream.target?.startsWith('schedule_day_')) {
      this.close()
    }
  }

  onFrameLoad() {
    this.setupBulkFormSync()
    this.open()
  }

  handleSubmitEnd = (event) => {
    const form = event.target
    if (!this.element.contains(form)) return

    if (event.detail.success) {
      const submitter = event.detail.formSubmission?.submitter
      if (submitter && submitter.value === 'save_and_add') {
        return
      }
      this.close()
    }
  }

  setupBulkFormSync() {
    const formatSelect = this.element.querySelector('select.session-format')
    const durationInput = this.element.querySelector('.time-slot-duration')

    if (formatSelect && durationInput) {
      formatSelect.addEventListener('change', () => {
        durationInput.value = formatSelect.value
      })

      durationInput.addEventListener('keyup', () => {
        if (document.activeElement === durationInput) {
          formatSelect.value = ''
        }
      })
    }
  }

  open() {
    Modal.getOrCreateInstance(this.element).show()
  }

  close() {
    const modal = Modal.getInstance(this.element)
    if (modal) modal.hide()
  }
}
