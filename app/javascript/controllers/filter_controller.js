import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'content', 'form', 'container', 'visibleCount' ]

  initialize() {
    this.filters = []
    this.filterClass = this.element.dataset.filterElementSlug
    this.updateVisibleCounts()
  }

  inputChange(e) {
    const filterValue = e.target.value

    if (e.target.checked) {
      this.addNewFliter(filterValue)
    } else {
      this.removeFilterOn(filterValue)
    }

    this.applyFilter()
  }

  addNewFliter(filterValue) {
    this.filters.push(filterValue);
  }

  removeFilterOn(filterValue) {
    this.filters = this.filters.filter((value) => value != filterValue )
  }

  async applyFilter() {
    this.showAllContent()
    await this.containerTargets.forEach((container) => this.filterContainer(container));
    this.updateVisibleCounts()
  }

  filterContainer(container) {
    if (this.filters.length === 0) {
      this.showAllContent()
      return
    }

    let content = container.querySelectorAll(`${this.filterClass}`)

    content.forEach((ele) => {
      const hasClass = this.filters.filter((incClass) => ele.classList.contains(incClass))
      if (hasClass.length > 0) {
        this.revealElement(ele)
      } else {
        this.hideElement(ele)
      }
    })
  }

  clearFilter(e) {
    this.formTarget.reset();
    this.filters = [];
    this.showAllContent();
    this.updateVisibleCounts()
  }

  updateVisibleCounts() {
    this.visibleCountTargets.forEach((countDisplay, index) => {

      const parent = this.containerTargets[index]
      const total = parent.querySelectorAll(this.filterClass).length
      const visible = total - parent.querySelectorAll(`${this.filterClass}.hidden`).length

      countDisplay.innerHTML = total != visible ? `(${visible}/${total})` : `(${total})`
    })
  }

  hideElement(element) {
    element.classList.add('hidden')
  }

  revealElement(element) {
    element.classList.remove('hidden')
  }

  showAllContent() {
    this.contentTargets.forEach((ele) => this.revealElement(ele) )
  }
}