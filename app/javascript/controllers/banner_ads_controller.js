import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'ad' ]
  static values = {
    eventSlug: String,
  }

  connect() {
    const path = `/${this.eventSlugValue}/banner_ads`
    fetch(path)
      .then((res) => res.text())
      .then((html) => {
        const fragment = document
          .createRange()
          .createContextualFragment(html);
        this.element.appendChild(fragment);

        this.config()
      })
  }

  config() {
    this.setAdInterval()
    this.setIndex()

    this.showCurrentIndex()
    this.startAdRotation()
  }

  showCurrentIndex() {
    this.adTargets.forEach((ad, index) => {
      ad.hidden = index != this.index;
    })
  }

  setAdInterval() {
    this.adInterval = 7500; // 7.5 second ad interval
  }

  setIndex() {
    this.index = Math.floor(Math.random() * this.adTargets.length);
  }

  startAdRotation() {
    setInterval(() => {

      this.index += 1
      if (this.index >= this.adTargets.length) {
        this.index = 0
      }

      this.showCurrentIndex()
    }, this.adInterval)
  }
}
