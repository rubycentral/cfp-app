import { Controller } from '@hotwired/stimulus'
import { Turbo } from '@hotwired/turbo-rails'

export default class extends Controller {
  static targets = ['display', 'edit']

  show(e) {
    e.preventDefault()
    this.displayTarget.style.display = 'none'
    this.editTarget.style.display = 'block'
  }

  cancel(e) {
    e.preventDefault()
    this.editTarget.style.display = 'none'
    this.displayTarget.style.display = ''
  }

  submitAndClose(e) {
    const form = e.target.closest('form')
    if (form) {
      form.addEventListener('turbo:submit-end', (event) => {
        if (event.detail.success) {
          this.editTarget.style.display = 'none'
          this.displayTarget.style.display = ''
        }
      }, { once: true })
      Turbo.navigator.submitForm(form)
    }
  }
}
