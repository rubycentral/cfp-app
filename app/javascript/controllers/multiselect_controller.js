import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    const isReviewTags = this.element.classList.contains('review-tags')
    const labelClass = isReviewTags ? 'label label-success' : 'label label-primary'

    new TomSelect(this.element, {
      plugins: ['remove_button'],
      render: {
        item: (data, escape) => '<div class="' + labelClass + '" style="margin-right: 4px;">' + escape(data.text) + '</div>'
      }
    })
  }
}
