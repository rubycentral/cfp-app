import { Controller } from "stimulus"
import CodeMirror from 'codemirror/lib/codemirror.js'
import 'codemirror/lib/codemirror.css'
import 'codemirror/mode/htmlmixed/htmlmixed.js'

export default class extends Controller {
  static targets = ['textArea', 'wysiwyg', 'html']
  connect() {
  }

  editHtml(e) {
    e.preventDefault();
    this.wysiwygTarget.classList.add("hidden");
    this.htmlTarget.classList.remove("hidden");
    this.textAreaTarget.disabled = false;
    var editor = CodeMirror.fromTextArea(this.textAreaTarget, {
      value: this.wysiwygEditor.value,
      mode: "htmlmixed",
      lineWrapping: true,
    });
    for (var i=0;i<editor.lineCount();i++) { editor.indentLine(i); }
  }

  wysiwyg(e) {
    e.preventDefault();
    this.wysiwygTarget.classList.remove("hidden");
    this.htmlTarget.classList.add("hidden");
    this.textAreaTarget.disabled = true;
    this.wysiwygEditor.value = this.htmlEditor.getValue();
    this.htmlEditor.toTextArea();
  }

  get wysiwygEditor() {
    return document.querySelector('trix-editor');
  }

  get htmlEditor() {
    return document.querySelector('.CodeMirror').CodeMirror;
  }
}
