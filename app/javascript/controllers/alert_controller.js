import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['message']

  close() {
    this.element.remove()
  }

  show(messages) {
    if (!Array.isArray(messages)) {
      messages = [messages]
    }

    const html = messages.map(msg => `<li>${msg}</li>`).join('')
    this.messageTarget.innerHTML = `<ul>${html}</ul>`
    this.element.style.display = 'block'
  }

  hide() {
    this.element.style.display = 'none'
    this.messageTarget.innerHTML = ''
  }
}
