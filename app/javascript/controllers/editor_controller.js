import { Controller } from 'stimulus'
import CodeMirror from 'codemirror/lib/codemirror.js'
import 'codemirror/lib/codemirror.css'
import 'codemirror/mode/htmlmixed/htmlmixed.js'

export default class extends Controller {
  static targets = ['htmlContent', 'wysiwygContent', 'wysiwyg', 'html']

  initialize () {
    this.defaults = {
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
      ' removeformat | code | help',
      valid_elements: '*[*]',
      forced_root_block : '',
      init_instance_callback: function(editor) {
        editor.on('input', function(e) {
          var preview = document.getElementById('page-preview');
          preview.contentWindow.document.getElementById("content").innerHTML = e.target.innerHTML;
        });
      }
    }
  }

  editHtml(e) {
    e.preventDefault();
    this.wysiwygTarget.classList.add("hidden");
    this.htmlTarget.classList.remove("hidden");
    this.htmlContentTarget.disabled = false;
    var editor = CodeMirror.fromTextArea(this.htmlContentTarget, {
      mode: "htmlmixed",
      lineWrapping: true,
    });
    editor.setValue(this.wysiwygEditor.getContent());
    for (var i=0;i<editor.lineCount();i++) { editor.indentLine(i); }
    editor.on('change', function(e) {
      var preview = document.getElementById('page-preview');
      preview.contentWindow.document.getElementById("content").innerHTML = e.getValue();
    })
  }

  wysiwyg(e) {
    e.preventDefault();
    this.wysiwygTarget.classList.remove("hidden");
    this.htmlTarget.classList.add("hidden");
    this.htmlContentTarget.disabled = true;
    this.wysiwygEditor.setContent(this.htmlEditor.getValue());
    this.htmlEditor.toTextArea();
  }

  get wysiwygEditor() {
    return tinyMCE.activeEditor;
  }

  get htmlEditor() {
    return document.querySelector('.CodeMirror').CodeMirror;
  }

  connect () {
    let config = Object.assign({ target: this.wysiwygContentTarget }, this.defaults)
    tinyMCE.init(config)
  }

  disconnect () {
    tinyMCE.remove()
  }
}
