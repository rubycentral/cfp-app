import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    const padTop = this.element.offsetHeight
    document.body.style.paddingTop = (parseInt(getComputedStyle(document.body).paddingTop) + padTop) + 'px'
  }
}
