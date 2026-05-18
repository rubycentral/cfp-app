import { Controller } from '@hotwired/stimulus'
import { createConsumer } from '@rails/actioncable'

export default class extends Controller {
  connect() {
    this.consumer = createConsumer()
    this.subscription = this.consumer.subscriptions.create('NotificationsChannel', {
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
    if (this.consumer) {
      this.consumer.disconnect()
    }
  }
}
