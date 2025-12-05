import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  static targets = ["modal"]

  submitEnd(event) {
    if (event.detail.success) {
      // Check if 'save_and_add' button was clicked
      const formData = event.detail.formSubmission?.formElement ? new FormData(event.detail.formSubmission.formElement) : null
      const submitter = event.detail.formSubmission?.submitter
      if (submitter && submitter.value === 'save_and_add') {
        // Don't hide modal for "Save and Add"
        return
      }
      const modal = Modal.getInstance(this.modalTarget)
      if (modal) modal.hide()
    }
  }
}
