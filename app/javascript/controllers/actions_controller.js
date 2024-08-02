import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.updateButtons()
  }

  updateButtons() {
    this.buttonTargets.forEach(button => {
      // ボタンの状態を更新するロジックをここに記述
    })
  }

  async toggleAction(event) {
    event.preventDefault()
    const url = event.currentTarget.href

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
        'Accept': 'text/vnd.turbo-stream.html'
      }
    })

    if (response.ok) {
      const html = await response.text()
      Turbo.renderStreamMessage(html)
      this.updateButtons()
    }
  }
}
