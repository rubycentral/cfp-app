import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"
import moment from 'moment'

export default class extends Controller {
  static targets = ['proposals', 'supplementalFields', 'sessionInfo', 'startTime', 'endTime', 'length',
                    'infoTitle', 'infoTrack', 'infoSpeaker', 'infoAbstract', 'infoDuration']

  connect() {
    const modalElement = this.element.closest('.modal')
    this.updateInfoFields()
    this.updateLength()

    if (!modalElement.classList.contains('show')) {
      const modal = Modal.getOrCreateInstance(modalElement)
      modal.show()
    }
  }

  onSessionChange() {
    this.updateInfoFields()
  }

  onTimeChange() {
    this.updateLength()
  }

  updateInfoFields() {
    if (!this.hasProposalsTarget) return

    const selected = this.proposalsTarget.selectedOptions[0]
    const data = selected?.dataset || {}

    if (this.hasInfoTitleTarget) this.infoTitleTarget.innerHTML = data.title || ''
    if (this.hasInfoTrackTarget) this.infoTrackTarget.innerHTML = data.track || ''
    if (this.hasInfoSpeakerTarget) this.infoSpeakerTarget.innerHTML = data.speaker || ''
    if (this.hasInfoAbstractTarget) this.infoAbstractTarget.innerHTML = data.abstract || ''
    if (this.hasInfoDurationTarget) this.infoDurationTarget.innerHTML = (data.duration || '') + ' minutes'

    if (selected?.value === '') {
      if (this.hasSupplementalFieldsTarget) this.supplementalFieldsTarget.classList.remove('hidden')
      if (this.hasSessionInfoTarget) this.sessionInfoTarget.classList.add('hidden')
    } else {
      if (this.hasSupplementalFieldsTarget) this.supplementalFieldsTarget.classList.add('hidden')
      if (this.hasSessionInfoTarget) this.sessionInfoTarget.classList.remove('hidden')
    }
  }

  updateLength() {
    if (!this.hasStartTimeTarget || !this.hasEndTimeTarget || !this.hasLengthTarget) return

    const start = this.startTimeTarget.value
    const end = this.endTimeTarget.value

    if (start && end) {
      const s = moment(start, 'HH:mm')
      const e = moment(end, 'HH:mm')
      const diff = e.diff(s, 'minutes')
      this.lengthTarget.textContent = diff + ' minutes'
    }
  }
}
