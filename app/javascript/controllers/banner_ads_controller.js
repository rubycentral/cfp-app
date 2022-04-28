import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [ 'ad' ]
  static values = {
    eventSlug: String,
    index: Number,
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

        this.showCurrentIndex()
        this.setAdInterval()
        this.startAdRotation()
      })
  }

  showCurrentIndex() {
    this.adTargets.forEach((ad, index) => {
      ad.hidden = index != this.indexValue;
    })
  }

  setAdInterval() {
    this.adInterval = 7500; // 7.5 second ad interval
  }

  startAdRotation() {
    setInterval(() => {
      this.indexValue += 1
      if (this.indexValue >= this.adTargets.length) {
        this.indexValue = 0
      }
    }, this.adInterval)
  }

  indexValueChanged() {
    this.showCurrentIndex()
  }
}
