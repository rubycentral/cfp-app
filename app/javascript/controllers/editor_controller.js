import { Controller } from '@hotwired/stimulus'

const TINYMCE_VERSION = '6.8.0'
const TINYMCE_CDN_URL = `https://cdn.jsdelivr.net/npm/tinymce@${TINYMCE_VERSION}/tinymce.min.js`
const CODEMIRROR_VERSION = '5.65.16'
const CODEMIRROR_CDN_BASE = `https://cdn.jsdelivr.net/npm/codemirror@${CODEMIRROR_VERSION}`

export default class extends Controller {
  static targets = ['htmlContent', 'wysiwygContent', 'wysiwyg', 'html']
  static values = { changed: { type: Boolean, default: false } }

  initialize () {
    this.tinyMCELoaded = this.loadTinyMCE()
    this.codeMirrorLoaded = this.loadCodeMirror()
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
    this.initializeCodeMirror(this.wysiwygEditor.getContent());
  }

  initializeCodeMirror(content) {
    var editor = CodeMirror.fromTextArea(this.htmlContentTarget, {
      mode: "htmlmixed",
      lineWrapping: true,
    });
    if (content) {
      editor.setValue(content);
    }
    this.indentCodeMirror(editor);
    editor.on('change', (e) => {
      this.changedValue = true;
      this.preview(e.getValue());
    })
    editor.on('drop', (e, event) => {
      event.preventDefault();
      this.uploadFile(event.dataTransfer.files[0], event, e)
    })
    return editor;
  }

  indentCodeMirror(editor) {
    for (var i=0;i<editor.lineCount();i++) { editor.indentLine(i); }
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
    if (this.changedValue) {
      event.returnValue = "Are you sure you want to leave with unsaved changes?";
      return event.returnValue;
    }
  }

  allowFormSubmission(event) {
    this.changedValue = false;
  }

  loadTinyMCE() {
    if (window.tinyMCE) {
      return Promise.resolve()
    }

    return new Promise((resolve, reject) => {
      const script = document.createElement('script')
      script.src = TINYMCE_CDN_URL
      script.onload = resolve
      script.onerror = reject
      document.head.appendChild(script)
    })
  }

  loadCodeMirror() {
    if (window.CodeMirror) {
      return Promise.resolve()
    }

    return new Promise((resolve, reject) => {
      const script = document.createElement('script')
      script.src = `${CODEMIRROR_CDN_BASE}/lib/codemirror.min.js`
      script.onload = () => {
        // Load htmlmixed mode after core is loaded
        const modeScript = document.createElement('script')
        modeScript.src = `${CODEMIRROR_CDN_BASE}/mode/htmlmixed/htmlmixed.min.js`
        modeScript.onload = () => {
          // htmlmixed depends on xml, javascript, and css modes
          const xmlScript = document.createElement('script')
          xmlScript.src = `${CODEMIRROR_CDN_BASE}/mode/xml/xml.min.js`
          const jsScript = document.createElement('script')
          jsScript.src = `${CODEMIRROR_CDN_BASE}/mode/javascript/javascript.min.js`
          const cssScript = document.createElement('script')
          cssScript.src = `${CODEMIRROR_CDN_BASE}/mode/css/css.min.js`

          let loaded = 0
          const onLoad = () => {
            loaded++
            if (loaded === 3) resolve()
          }
          xmlScript.onload = onLoad
          jsScript.onload = onLoad
          cssScript.onload = onLoad
          xmlScript.onerror = reject
          jsScript.onerror = reject
          cssScript.onerror = reject

          document.head.appendChild(xmlScript)
          document.head.appendChild(jsScript)
          document.head.appendChild(cssScript)
        }
        modeScript.onerror = reject
        document.head.appendChild(modeScript)
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

  async connect () {
    await Promise.all([this.tinyMCELoaded, this.codeMirrorLoaded])
    let config = Object.assign({ target: this.wysiwygContentTarget }, this.tinyMCEDefaults)
    tinyMCE.init(config)
    this.initializeCodeMirror();
  }

  disconnect () {
    tinyMCE.remove()
  }
}
