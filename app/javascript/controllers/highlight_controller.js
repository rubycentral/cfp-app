import { Controller } from '@hotwired/stimulus'
import hljs from 'highlight.js'
import 'highlight.js/styles/github.css'

export default class extends Controller {
  connect() {
    this.element.querySelectorAll('pre code').forEach((block) => {
      if (!block.dataset.highlighted) {
        hljs.highlightElement(block)
      }
    })
  }
}
