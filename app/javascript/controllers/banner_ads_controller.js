import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ 'ad' ]
  static values = {
    eventSlug: String,
  }

  connect() {
    this.config()
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
