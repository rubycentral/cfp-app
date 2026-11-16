import { Controller } from "@hotwired/stimulus"

// Light / dark / auto theme toggle in the navbar.
//
// The preference lives in localStorage['theme'] ('light', 'dark' or 'auto'; anything
// else means 'auto'). 'auto' follows prefers-color-scheme. The resolved theme is written
// to <html data-bs-theme>, which Bootstrap, DataTables and css-colors.css read. The
// inline script in layouts/application.html.haml applies the same logic before first
// paint; this controller owns the button and reacts to clicks and OS changes.
const ORDER = ['auto', 'light', 'dark']
const ICONS = {auto: 'bi-circle-half', light: 'bi-sun-fill', dark: 'bi-moon-stars-fill'}

export default class extends Controller {
  static targets = ['button', 'icon']

  connect() {
    this.preference = this.storedPreference()
    this.mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    this.onSchemeChange = () => { if (this.preference === 'auto') this.apply() }
    this.mediaQuery.addEventListener('change', this.onSchemeChange)
    this.apply()
    this.render()
  }

  disconnect() {
    this.mediaQuery.removeEventListener('change', this.onSchemeChange)
  }

  cycle() {
    this.preference = ORDER[(ORDER.indexOf(this.preference) + 1) % ORDER.length]
    try { localStorage.setItem('theme', this.preference) } catch (e) {}
    this.apply()
    this.render()
  }

  apply() {
    const theme = this.resolve()
    document.documentElement.dataset.bsTheme = theme
    window.dispatchEvent(new CustomEvent('theme:changed', {detail: {theme, preference: this.preference}}))
  }

  resolve() {
    if (this.preference === 'auto') return this.mediaQuery.matches ? 'dark' : 'light'
    return this.preference
  }

  render() {
    const next = ORDER[(ORDER.indexOf(this.preference) + 1) % ORDER.length]
    const label = `Theme: ${this.preference} (click for ${next})`
    this.buttonTarget.title = label
    this.buttonTarget.setAttribute('aria-label', label)
    this.iconTarget.className = `bi ${ICONS[this.preference]}`
  }

  storedPreference() {
    let pref = 'auto'
    try { pref = localStorage.getItem('theme') || 'auto' } catch (e) {}
    return ORDER.includes(pref) ? pref : 'auto'
  }
}
