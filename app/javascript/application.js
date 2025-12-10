// Entry point for the build script in your package.json

import "@hotwired/turbo-rails"
import { Turbo } from "@hotwired/turbo-rails"

// Disable Turbo Drive globally - opt-in instead of opt-out for existing app
Turbo.session.drive = false

import "./controllers"
