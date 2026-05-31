import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "overlay"]

  connect() {
    this._loaded = false
    this._bound = this._handleKeydown.bind(this)
    document.addEventListener("keydown", this._bound)
  }

  disconnect() {
    document.removeEventListener("keydown", this._bound)
  }

  open(event) {
    event.preventDefault()
    this.panelTarget.classList.remove("hidden")
    this.overlayTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")

    if (!this._loaded) {
      const frame = this.panelTarget.querySelector("turbo-frame")
      if (frame) frame.src = frame.dataset.src
      this._loaded = true
    }
  }

  close() {
    this.panelTarget.classList.add("hidden")
    this.overlayTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  _handleKeydown(e) {
    if (e.key === "Escape") this.close()
  }
}
