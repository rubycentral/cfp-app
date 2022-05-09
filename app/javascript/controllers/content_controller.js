import { Controller } from 'stimulus'
import CodeMirror from 'codemirror/lib/codemirror.js'
import 'codemirror/mode/htmlmixed/htmlmixed.js'

export default class extends Controller {
  static targets = ['textArea']

  initializeCodeMirror() {
    var editor = CodeMirror.fromTextArea(this.textAreaTarget, {
      mode: "htmlmixed",
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

  connect () {
    this.initializeCodeMirror();
  }
}
