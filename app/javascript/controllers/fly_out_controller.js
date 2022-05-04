import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'sidePanel', 'programSession' ]
  static values = { revealedElement: String }

  updateSidePanel(e) {
    e.preventDefault();
    this.hideAll();

    const toShow = document.getElementById(`program-session-detail-${e.target.dataset.sessionId}`);
    if(!!toShow) {
      toShow.classList.remove('hidden');
      this.openSidePanel();
    }
  }

  hideAll() {
    this.programSessionTargets.forEach(element => {
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
