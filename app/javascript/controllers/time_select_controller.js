import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.buffer = ""
    this.timeout = null
    // Prevent native type-ahead by capturing keypress as well
    this.element.addEventListener('keypress', this.preventNativeTypeAhead.bind(this))
  }

  disconnect() {
    this.element.removeEventListener('keypress', this.preventNativeTypeAhead.bind(this))
  }

  preventNativeTypeAhead(event) {
    if (/^\d$/.test(event.key)) {
      event.preventDefault()
      event.stopPropagation()
    }
  }

  keydown(event) {
    // Only handle digit keys
    if (!/^\d$/.test(event.key)) {
      return
    }

    event.preventDefault()
    event.stopPropagation()
    event.stopImmediatePropagation()

    this.buffer += event.key

    // Clear buffer after 1 second of no typing
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.buffer = ""
    }, 1000)

    this.selectMatchingOption()
  }

  selectMatchingOption() {
    let timeStr = null

    if (this.buffer.length >= 4) {
      // "1530" → "15:30"
      timeStr = this.buffer.slice(0, 2) + ":" + this.buffer.slice(2, 4)
      this.buffer = ""
      clearTimeout(this.timeout)
    } else if (this.buffer.length === 3) {
      // "153" → "15:30" (assume last digit is tens of minutes)
      timeStr = this.buffer.slice(0, 2) + ":" + this.buffer.slice(2) + "0"
    } else if (this.buffer.length === 2) {
      // "15" → "15:00"
      timeStr = this.buffer + ":00"
    } else if (this.buffer.length === 1) {
      // "1" → "01:00"
      timeStr = "0" + this.buffer + ":00"
    }

    if (timeStr) {
      const option = this.element.querySelector(`option[value="${timeStr}"]`)
      if (option) {
        this.element.value = timeStr
        this.element.dispatchEvent(new Event('change', { bubbles: true }))
      }
    }
  }
}
