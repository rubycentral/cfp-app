// Entry point for the build script in your package.json

import * as Popper from "@popperjs/core"
import * as bootstrap from "bootstrap"
import "chartkick/chart.js"

// Initialize Bootstrap dropdowns
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-bs-toggle="dropdown"]').forEach(el => {
    new bootstrap.Dropdown(el)
  })
})

import "@hotwired/turbo-rails"
import { Turbo } from "@hotwired/turbo-rails"

// Disable Turbo Drive globally - opt-in instead of opt-out for existing app
Turbo.session.drive = false

import "./controllers"
