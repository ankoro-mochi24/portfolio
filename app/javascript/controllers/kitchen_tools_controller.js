import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="kitchen-tools"
export default class extends Controller {
  static targets = ["container", "template"]

  addField(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/TEMPLATE_RECORD/g, new Date().valueOf())
    this.containerTarget.insertAdjacentHTML("beforeend", content)
  }

  removeField(event) {
    event.preventDefault()
    if (this.containerTarget.childElementCount > 1) {
      event.target.closest(".nested-fields").remove()
    }
  }
}
