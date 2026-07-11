import { Controller } from '@hotwired/stimulus'

// Disables a form's submit buttons once it is submitted, so a double click
// cannot POST twice. Turbo Drive does this for opted-in forms, but this app
// disables Drive globally (application.js), so plain full-page forms get no
// protection from Turbo and rails-ujs (disable_with) is no longer bundled.
//
// Usage: form html: {data: {controller: 'disable-submit', action: 'submit->disable-submit#disable'}}
export default class extends Controller {
  disable(event) {
    // A handler registered before this one may have canceled the submission
    // (e.g. client-side validation) — leave the button usable then.
    if (event.defaultPrevented) return

    // Disable on the next tick: the browser builds the form data set after
    // the submit event finishes, and a button disabled too early would have
    // its own name/value dropped from the submission.
    setTimeout(() => {
      this.element.querySelectorAll('button[type="submit"], input[type="submit"]').forEach(button => {
        button.disabled = true
      })
    })
  }
}
