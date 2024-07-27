import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["body", "form"]

  connect() {
    console.log("Comment controller connected")
  }

  edit() {
    console.log("Edit button clicked")
    this.bodyTarget.classList.add("d-none")
    this.formTarget.classList.remove("d-none")
  }

  cancel() {
    console.log("Cancel button clicked")
    this.bodyTarget.classList.remove("d-none")
    this.formTarget.classList.add("d-none")
  }
}
