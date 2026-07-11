// Disable a form's submit buttons once it is submitted, so a double click
// cannot POST twice.
//
// rails-ujs (disable_with) is no longer bundled and Turbo Drive is disabled
// globally (application.js), so plain full-page forms — most forms in this
// app — get no double-submit protection from anywhere. This restores it in
// one place, like ujs used to, instead of per-form wiring that the next
// form silently misses.
//
// Turbo-managed forms (data-turbo="true", data-turbo-frame, or inside a
// <turbo-frame>) are left alone: Turbo already disables their submitter for
// the duration of the submission and re-enables/re-renders it afterwards.

const turboManaged = (form) =>
  form.dataset.turbo === 'true' || 'turboFrame' in form.dataset || !!form.closest('turbo-frame')

document.addEventListener('submit', (event) => {
  const form = event.target
  if (event.defaultPrevented) return
  // Turbo's opt-in can also live on the submitter (button_to data: {turbo: true}).
  if (turboManaged(form) || event.submitter?.dataset.turbo === 'true') return

  // Disable on the next tick: the browser builds the form data set after the
  // submit event finishes, and a button disabled too early would have its
  // own name/value pair dropped from the submission.
  setTimeout(() => {
    form.querySelectorAll('button[type="submit"], input[type="submit"]').forEach((button) => {
      button.disabled = true
    })
  })
})
