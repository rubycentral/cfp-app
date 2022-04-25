import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['input', 'preview']

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
        ' removeformat | code | help'
        ,
        init_instance_callback: function(editor) {
          editor.on('input', function(e) {
            var preview = document.getElementById('page-preview');
            preview.contentWindow.location.reload(true);
          });
        }
    }
  }

  connect () {
    let config = Object.assign({ target: this.inputTarget }, this.defaults)
    tinyMCE.init(config)
  }

  disconnect () {
    tinymce.remove()
  }
}
