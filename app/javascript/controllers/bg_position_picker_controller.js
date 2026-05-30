import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "modal", "previewImg", "slider", "positionInput", "mainPreview", "sliderValue"]

  open(event) {
    const file = event.target.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (e) => {
      this.previewImgTarget.src = e.target.result
      const current = this.positionInputTarget.value
      const pct = this.#parsePositionToPct(current)
      this.sliderTarget.value = pct
      this.#applySliderToPreview(pct)
      this.modalTarget.classList.remove("hidden")
    }
    reader.readAsDataURL(file)
  }

  updatePreview() {
    const val = this.sliderTarget.value
    this.#applySliderToPreview(val)
    if (this.hasSliderValueTarget) {
      this.sliderValueTarget.textContent = `${val}%`
    }
  }

  apply() {
    const val = this.sliderTarget.value
    this.positionInputTarget.value = `center ${val}%`
    if (this.hasMainPreviewTarget) {
      this.mainPreviewTarget.style.objectPosition = `center ${val}%`
    }
    this.modalTarget.classList.add("hidden")
  }

  cancel() {
    this.modalTarget.classList.add("hidden")
    this.fileInputTarget.value = ""
  }

  #applySliderToPreview(val) {
    this.previewImgTarget.style.objectPosition = `center ${val}%`
  }

  #parsePositionToPct(val) {
    if (!val) return 50
    if (val === "top") return 0
    if (val === "center") return 50
    if (val === "bottom") return 100
    const m = val.match(/(\d+)%/)
    return m ? parseInt(m[1]) : 50
  }
}
