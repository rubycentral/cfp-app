import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "icon", "form"]

  toggle() {
    this.displayTarget.classList.toggle('hidden')
    this.iconTarget.classList.toggle('hidden')

    // Slide toggle with CSS transition
    const form = this.formTarget
    if (form.classList.contains('hidden')) {
      form.classList.remove('hidden')
      form.style.maxHeight = form.scrollHeight + 'px'
    } else {
      form.style.maxHeight = '0'
      form.addEventListener('transitionend', () => {
        if (form.style.maxHeight === '0px') {
          form.classList.add('hidden')
        }
      }, { once: true })
    }
  }
}
