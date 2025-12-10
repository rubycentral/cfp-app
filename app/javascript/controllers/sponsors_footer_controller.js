import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    eventSlug: String
  }

  connect() {
    const path = `/${this.eventSlugValue}/sponsors_footer`
    fetch(path)
      .then((res) => res.text())
      .then((html) => {
        const fragment = document
          .createRange()
          .createContextualFragment(html);
        this.element.appendChild(fragment);
      })
  }
}