import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    this.showRating()
    if (this.hasFormTarget) {
      this.boundHandleChange = this.handleChange.bind(this)
      this.formTarget.addEventListener('change', this.boundHandleChange)
    }
  }

  disconnect() {
    if (this.hasFormTarget && this.boundHandleChange) {
      this.formTarget.removeEventListener('change', this.boundHandleChange)
    }
  }

  handleChange(event) {
    if (event.target.matches('.star-rating-select')) {
      // Uncheck all other checkboxes so only the clicked one is submitted
      this.formTarget.querySelectorAll('.star-rating-select').forEach(checkbox => {
        if (checkbox !== event.target) {
          checkbox.checked = false
        }
      })
      // Ensure the clicked checkbox is checked (unless it's the delete button)
      if (!event.target.classList.contains('delete')) {
        event.target.checked = true
      }
      this.formTarget.requestSubmit()
    }
  }

  preview(event) {
    const wrapper = event.currentTarget.closest('.star-wrapper')
    const allWrappers = this.element.querySelectorAll('.star-wrapper')

    allWrappers.forEach((w, index) => {
      const star = w.querySelector('.star .bi-star-fill')
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
        const star = wrapper.querySelector('.star .bi-star-fill')
        if (star) {
          if (index <= checkedIndex) {
            star.classList.add('starred')
          } else {
            star.classList.remove('starred')
          }
        }
      })
    } else {
      this.element.querySelectorAll('.star .bi-star-fill').forEach(star => {
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
