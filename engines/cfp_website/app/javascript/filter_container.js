class FilterContainer {
  constructor(element, type) {
    this.type = type;
    this.element = element;
  }

  subContainers() {
    let children = this.element.querySelectorAll(`.${this.element.dataset.subcontainerClass}`)
    return [...children];
  }

  updateApperance() {
    this.updateContainerApperance()

    if (this.subContainers().length > 0) {
      this.subContainers().forEach((child) => {
        this.updateContainerApperance(child)
      })
    }
  }

  updateContainerApperance(container = this.element) {
    if (this.visibleCount(container) > 0) {
      container.classList.remove('empty');
    } else {
      container.classList.add('empty');
    }
  }

  visibleCount(container = this.element) {
    return container.querySelectorAll(`${this.type}:not(.hidden)`).length
  }
}

export default FilterContainer;
