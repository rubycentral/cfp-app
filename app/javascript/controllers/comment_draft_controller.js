import { Controller } from '@hotwired/stimulus'

// Persists a textarea draft to localStorage so it survives a full page reload,
// mirroring GitHub's issue/PR comment draft behavior. Save on input (debounced),
// restore on connect, and clear the draft only once the comment was submitted
// successfully — a failed submission (network error, 5xx) must keep the draft.
export default class extends Controller {
  static values = { key: String }

  connect() {
    this.saveTimer = null
    this.form = this.element.closest('form')

    this.handleSubmitEnd = (event) => {
      if (event.detail.success) this.clear()
    }
    if (this.form) this.form.addEventListener('turbo:submit-end', this.handleSubmitEnd)

    this.restore()
  }

  disconnect() {
    // A successful submit re-renders the frame, so this disconnect must not
    // resurrect the just-cleared draft: flush only when a save is pending.
    this.flush()
    if (this.form) this.form.removeEventListener('turbo:submit-end', this.handleSubmitEnd)
  }

  // Restore the saved draft, but only when the textarea is empty so a
  // server-rendered value is never overwritten.
  restore() {
    if (this.element.value !== '') return

    const saved = this.read()
    if (saved === null || saved === '') return

    this.element.value = saved
    // Notify mention (Tribute) and other listeners of the restored value.
    this.element.dispatchEvent(new Event('input', { bubbles: true }))
  }

  // Debounced save triggered by the textarea's input event.
  save() {
    if (this.saveTimer) clearTimeout(this.saveTimer)

    this.saveTimer = setTimeout(() => {
      this.saveTimer = null
      this.persist()
    }, 300)
  }

  // Write a pending (debounced but not yet saved) draft immediately.
  flush() {
    if (!this.saveTimer) return

    clearTimeout(this.saveTimer)
    this.saveTimer = null
    this.persist()
  }

  persist() {
    const value = this.element.value
    if (value === '') {
      this.remove()
    } else {
      this.write(value)
    }
  }

  // Clear the draft on successful submit so the posted comment is not
  // restored on reload.
  clear() {
    if (this.saveTimer) {
      clearTimeout(this.saveTimer)
      this.saveTimer = null
    }
    this.remove()
  }

  read() {
    try {
      return localStorage.getItem(this.keyValue)
    } catch (e) {
      return null
    }
  }

  write(value) {
    try {
      localStorage.setItem(this.keyValue, value)
    } catch (e) {
      // Ignore private-mode / quota errors; drafting is best-effort.
    }
  }

  remove() {
    try {
      localStorage.removeItem(this.keyValue)
    } catch (e) {
      // Ignore private-mode errors.
    }
  }
}
