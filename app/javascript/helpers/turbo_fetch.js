import { Turbo } from '@hotwired/turbo-rails'

export function getCsrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content
}

export function turboStreamFetch(url, options = {}) {
  const { method = 'PATCH', body = '' } = options

  return fetch(url, {
    method,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'text/vnd.turbo-stream.html',
      'X-CSRF-Token': getCsrfToken()
    },
    body
  })
    .then(response => response.text())
    .then(html => Turbo.renderStreamMessage(html))
}
