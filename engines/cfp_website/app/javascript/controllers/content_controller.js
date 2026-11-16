import { Controller } from '@hotwired/stimulus'

const CODEMIRROR_VERSION = '5.65.16'
const CODEMIRROR_CDN_BASE = `https://cdn.jsdelivr.net/npm/codemirror@${CODEMIRROR_VERSION}`

export default class extends Controller {
  static targets = ['textArea']

  initialize() {
    this.codeMirrorLoaded = this.loadCodeMirror()
  }

  loadCodeMirror() {
    if (window.CodeMirror) {
      return Promise.resolve()
    }

    return new Promise((resolve, reject) => {
      const script = document.createElement('script')
      script.src = `${CODEMIRROR_CDN_BASE}/lib/codemirror.min.js`
      script.onload = () => {
        // Load css mode after core is loaded
        const cssScript = document.createElement('script')
        cssScript.src = `${CODEMIRROR_CDN_BASE}/mode/css/css.min.js`
        cssScript.onload = resolve
        cssScript.onerror = reject
        document.head.appendChild(cssScript)
      }
      script.onerror = reject
      document.head.appendChild(script)

      // Load CSS
      const link = document.createElement('link')
      link.rel = 'stylesheet'
      link.href = `${CODEMIRROR_CDN_BASE}/lib/codemirror.min.css`
      document.head.appendChild(link)
    })
  }

  initializeCodeMirror() {
    var editor = CodeMirror.fromTextArea(this.textAreaTarget, {
      mode: 'css',
      lineWrapping: true,
    });
    editor.on('drop', (e, event) => {
      event.preventDefault();
      this.uploadFile(event.dataTransfer.files[0], event, e)
    })
    return editor;
  }

  uploadFile(file, event, editor) {
    let url = '/image_uploads'
    let formData = new FormData()

    formData.append('file', file)

    fetch(url, {
      method: 'POST',
      body: formData
    }).then(response => response.json())
      .then(data => {
        let newline = `url('${data.location}')`
        let doc= editor.getDoc()
        editor.focus()
        let x = event.pageX
        let y = event.pageY
        editor.setCursor(editor.coordsChar({left:x,top:y}))
        let newpos = editor.getCursor()
        doc.replaceRange(newline, newpos)
      })
  }

  async connect () {
    await this.codeMirrorLoaded
    this.initializeCodeMirror();
  }
}
