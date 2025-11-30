import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['form']
  static values = { url: String }

  async refresh() {
    const formData = new FormData(this.formTarget)
    formData.delete('_method')
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    const response = await fetch(this.urlValue, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Accept': 'text/html'
      },
      body: formData
    })

    if (response.ok) {
      const html = await response.text()
      const frame = document.getElementById('proposal-preview-frame')
      if (frame) {
        frame.innerHTML = html
      }
    }
  }
}
