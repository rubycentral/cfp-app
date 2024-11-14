import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'sidePanel', 'listItem', 'filterWrapper' ]

  toggleFilter(e) {
    e.preventDefault()
    this.hideAll()

    if (this.filterHidden()) {
      this.showFilter()
      this.openSidePanel()
    } else {
      this.hideFilter()
      this.closeSidePanel()
    }
  }

  updateSidePanel(e) {
    e.preventDefault();
    this.hideAll();
    this.hideFilter();

    const toShow = document.getElementById(e.target.dataset.sessionId);
    if(!!toShow) {
      toShow.classList.remove('hidden');
      this.openSidePanel();
    }
  }

  filterHidden() {
    return this.filterWrapperTarget.classList.contains('hidden')
  }

  showFilter() {
    this.filterWrapperTarget.classList.remove('hidden')
  }

  hideFilter() {
    this.filterWrapperTarget.classList.add('hidden')
  }

  hideAll() {
    this.listItemTargets.forEach(element => {
      element.classList.add('hidden');
    })
  }

  close(e) {
    e.preventDefault();
    e.stopPropagation();
    this.closeSidePanel();
  }

  closeSidePanel() {
    this.sidePanelTarget.classList.remove('open');
    this.sidePanelTarget.classList.add('closed');
  }

  openSidePanel() {
    this.sidePanelTarget.classList.remove('closed');
    this.sidePanelTarget.classList.add('open');
  }
}
