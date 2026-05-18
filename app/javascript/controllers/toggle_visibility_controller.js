import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = [ 'hidden' ]

  hidden() {
    return this.hiddenTarget
  }

  toggleHidden() {
    if (this.hidden().classList.contains('hidden')) {
      this.hidden().classList.remove('hidden');
    } else {
      this.hidden().classList.add('hidden');
    }
  }
}