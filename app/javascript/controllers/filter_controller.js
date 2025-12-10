import { Controller } from '@hotwired/stimulus'
import FilterContainer from '../filter_container'

export default class extends Controller {
  static values = { type: String }
  static targets = [ 'content', 'form', 'container', 'visibleCount' ]


  initialize() {
    this.filters = []
    this.filterClass = this.element.dataset.filterElementSlug
    this.filterContainers = this.containerTargets.map((container) => {
      return new FilterContainer(container, this.element.dataset.filterElementSlug)
    })

    this.updateVisibleCounts()
    this.updateContainerEmptyClass()
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

  applyFilter() {
    this.showAllContent()
    this.containerTargets.forEach((container) => this.filterContainer(container));
    this.updateVisibleCounts()
    this.updateContainerEmptyClass()
  }

  updateContainerEmptyClass() {
    this.filterContainers.forEach((container) => {
      container.updateApperance()
    })
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
    this.updateContainerEmptyClass()
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