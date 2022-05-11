import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'content', 'form', 'container', 'visibleCount' ]

  connect() {
    this.filters = []
    this.initializeVisibleCounts()
  }

  inputChange(e) {
    const filterValue = e.target.value

    if (e.target.checked) {
      this.removeFilterOn(filterValue)
    } else {
      this.addNewFliter(filterValue)
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
  }

  filterContainer(container) {
    this.filters.forEach((value) => {
      const toHide = container.querySelectorAll(`.${value}`)
      toHide.forEach(ele => ele.hidden = true )
      this.updateVisibleCount(container)
    })
  }

  showAllContent() {
    this.contentTargets.forEach((element) => element.hidden = false)
  }

  clearFilter(e) {
    this.formTarget.reset();
    this.filters = [];
    this.showAllContent();
    this.initializeVisibleCounts()
  }

  updateVisibleCount(container) {
    const index = this.containerTargets.indexOf(container)
    const total = container.children.length
    const visible = total - container.querySelectorAll("[hidden]").length
    this.visibleCountTargets[index].innerHTML = `(${visible}/${total})`
  }

  initializeVisibleCounts() {
    this.visibleCountTargets.forEach((countDisplay, index) => {
      const childCount = this.containerTargets[index].children.length
      countDisplay.innerHTML = `(${childCount})`
    })
  }
}