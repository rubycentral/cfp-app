import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    $('#time_slot_title').val('')
    $('#time_slot_presenter').val('')
    $('#time_slot_description').val('')
    $('#time_slot_program_session_id').val('').change()
    $("#time-slot-new-dialog .errors").html('')

    this.element.remove()
  }
}
