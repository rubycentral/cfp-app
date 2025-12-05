import { Controller } from "@hotwired/stimulus"
import { Popover } from "bootstrap"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    this.showRating()
    this.setupPopover()
    this.boundHandleChange = this.handleChange.bind(this)
    this.formTarget.addEventListener('change', this.boundHandleChange)
  }

  disconnect() {
    this.formTarget.removeEventListener('change', this.boundHandleChange)
    // Remove orphaned popover from body when frame is replaced
    document.querySelectorAll('.popover').forEach(el => el.remove())
  }

  handleChange(event) {
    if (event.target.matches('.star-rating-select')) {
      // Uncheck all other checkboxes so only the clicked one is submitted
      this.formTarget.querySelectorAll('.star-rating-select').forEach(checkbox => {
        if (checkbox !== event.target) {
          checkbox.checked = false
        }
      })
      this.formTarget.requestSubmit()
    }
  }

  setupPopover() {
    const toggle = this.element.querySelector('#rating-tooltip-toggle')
    if (toggle) {
      new Popover(toggle)
      toggle.addEventListener('click', (e) => e.preventDefault())
    }
  }

  preview(event) {
    const wrapper = event.currentTarget.closest('.star-wrapper')
    const allWrappers = this.element.querySelectorAll('.star-wrapper')

    allWrappers.forEach((w, index) => {
      const star = w.querySelector('.star .fa-star')
      if (star) {
        if (w === wrapper || this.isPreviousWrapper(allWrappers, wrapper, w)) {
          star.classList.add('starred')
        } else {
          star.classList.remove('starred')
        }
      }
    })
  }

  isPreviousWrapper(allWrappers, current, check) {
    const currentIndex = Array.from(allWrappers).indexOf(current)
    const checkIndex = Array.from(allWrappers).indexOf(check)
    return checkIndex < currentIndex
  }

  showRating() {
    const checkedWrapper = this.element.querySelector('.star-wrapper:has(input:checked)')
    if (checkedWrapper) {
      const allWrappers = Array.from(this.element.querySelectorAll('.star-wrapper'))
      const checkedIndex = allWrappers.indexOf(checkedWrapper)
      allWrappers.forEach((wrapper, index) => {
        const star = wrapper.querySelector('.star .fa-star')
        if (star) {
          if (index <= checkedIndex) {
            star.classList.add('starred')
          } else {
            star.classList.remove('starred')
          }
        }
      })
    } else {
      this.element.querySelectorAll('.star .fa-star').forEach(star => {
        star.classList.remove('starred')
      })
    }
  }

  previewDelete() {
    this.element.querySelector('.star-rating')?.classList.add('preview-delete')
  }

  cancelPreviewDelete() {
    this.element.querySelector('.star-rating')?.classList.remove('preview-delete')
  }

  toggleCommentsAndRatings(event) {
    event.preventDefault()
    const link = event.currentTarget
    link.querySelectorAll('i').forEach(icon => icon.classList.toggle('hidden'))

    const widget = this.element.closest('[data-controller="rating"]')?.closest('.widget-card-alt') || this.element.closest('.widget-card-alt')
    if (widget) {
      widget.querySelector('.internal-comments')?.classList.toggle('hidden')
    }
    this.element.querySelector('#show-ratings')?.classList.toggle('hidden')
  }
}
