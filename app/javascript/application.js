// Entry point for the build script in your package.json

import * as Popper from "@popperjs/core"
import * as bootstrap from "bootstrap"
import "chartkick/chart.js"

// Initialize Bootstrap components
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-bs-toggle="dropdown"]').forEach(el => {
    new bootstrap.Dropdown(el)
  })
  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(el => {
    new bootstrap.Tooltip(el)
  })
  document.querySelectorAll('[data-bs-toggle="popover"]').forEach(el => {
    new bootstrap.Popover(el)
  })
})

import "@hotwired/turbo-rails"
import { Turbo } from "@hotwired/turbo-rails"

// Disable Turbo Drive globally - opt-in instead of opt-out for existing app
Turbo.session.drive = false

// Disable browser's automatic scroll restoration on page reload
if ('scrollRestoration' in history) {
  history.scrollRestoration = 'manual'
}

// Custom Turbo Stream actions for DataTables
import "./turbo_stream_actions"

import "./controllers"
