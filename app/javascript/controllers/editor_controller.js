import { Controller } from 'stimulus'
import CodeMirror from 'codemirror/lib/codemirror.js'
import 'codemirror/mode/htmlmixed/htmlmixed.js'

export default class extends Controller {
  static targets = ['htmlContent', 'wysiwygContent', 'wysiwyg', 'html']
  static values = { changed: { type: Boolean, default: false } }

  initialize () {
    this.tinyMCEDefaults = {
      height: 500,
      menubar: false,
      plugins: [
        'advlist autolink lists link image charmap print preview anchor',
        'searchreplace visualblocks code fullscreen',
        'insertdatetime media table paste code help wordcount'
      ],
      toolbar: 'undo redo | formatselect | ' +
      ' bold italic backcolor | alignleft aligncenter ' +
      ' alignright alignjustify | bullist numlist outdent indent | ' +
      ' removeformat | image code | help',
      valid_elements: '*[*]',
      forced_root_block : '',
      images_upload_url: '/image_uploads',
      images_file_types: 'jpeg,jpg,jpe,jfi,jif,jfif,png,gif,bmp,webp,svg',
      relative_urls: false,
      convert_urls: false,
      init_instance_callback: (editor) => {
        editor.on('input', (e) => {
          this.preview(e.target.innerHTML);
          this.changedValue = true;
        });
        editor.on('change', (e) => {
          this.preview(e.target.getContent());
          this.changedValue = true;
        });
      }
    }
  }

  editHtml(e) {
    e.preventDefault();
    this.wysiwygTarget.classList.add("hidden");
    this.htmlTarget.classList.remove("hidden");
    this.htmlContentTarget.disabled = false;
    this.initializeCodeMirror().setValue(this.wysiwygEditor.getContent());
  }

  initializeCodeMirror() {
    var editor = CodeMirror.fromTextArea(this.htmlContentTarget, {
      mode: "htmlmixed",
      lineWrapping: true,
    });
    for (var i=0;i<editor.lineCount();i++) { editor.indentLine(i); }
    editor.on('change', (e) => {
      console.log(this.changedValue);
      this.changedValue = true;
      this.preview(e.getValue());
    })
    editor.on('drop', (e, event) => {
      event.preventDefault();
      this.uploadFile(event.dataTransfer.files[0], event, e)
    })
    return editor;
  }

  preview(content) {
    this.debounce(function() {
      document.getElementById('hidden-preview').value = content;
      document.getElementById('preview-form').submit();
    }, 1000)
  }

  debounce(func, delay) {
    if(this.timeout) { clearTimeout(this.timeout) }
    this.timeout = setTimeout(func, delay);
  }

  wysiwyg(e) {
    e.preventDefault();
    this.wysiwygTarget.classList.remove("hidden");
    this.htmlTarget.classList.add("hidden");
    this.htmlContentTarget.disabled = true;
    this.wysiwygEditor.setContent(this.htmlEditor.getValue());
    this.htmlEditor.toTextArea();
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
        let newline = `<img src="${data.location}"/>`
        let doc= editor.getDoc()
        editor.focus()
        let x = event.pageX
        let y = event.pageY
        editor.setCursor(editor.coordsChar({left:x,top:y}))
        let newpos = editor.getCursor()
        doc.replaceRange(newline, newpos)
      })
  }

  get wysiwygEditor() {
    return tinyMCE.activeEditor;
  }

  get htmlEditor() {
    return document.querySelector('.CodeMirror').CodeMirror;
  }

  leavingPage(event) {
    console.log(this.changedValue);
    if (this.changedValue) {
      event.returnValue = "Are you sure you want to leave with unsaved changes?";
      return event.returnValue;
    }
  }

  allowFormSubmission(event) {
    this.changedValue = false;
  }

  connect () {
    let config = Object.assign({ target: this.wysiwygContentTarget }, this.tinyMCEDefaults)
    tinyMCE.init(config)
    this.initializeCodeMirror();
  }

  disconnect () {
    tinyMCE.remove()
  }
}
