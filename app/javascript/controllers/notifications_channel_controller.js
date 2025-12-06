import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.subscription = App.cable.subscriptions.create('NotificationsChannel', {
      connected: () => console.log('Connected to notifications channel'),
      disconnected: () => console.log('Disconnected from notifications channel'),
      received: (data) => {
        console.log('Received data:', data)
        document.getElementById('notifications').textContent = data.message
        if (data.complete === '1') {
          document.querySelector(`tr[data-state="${data.state}"]`)?.remove()
        }
      }
    })
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }
}
