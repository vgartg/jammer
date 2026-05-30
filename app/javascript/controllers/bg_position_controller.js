import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["btn", "img", "input"]

  setPosition(event) {
    const pos = event.currentTarget.dataset.position
    this.inputTarget.value = pos
    this.imgTarget.style.objectPosition = pos

    this.btnTargets.forEach(btn => {
      if (btn.dataset.position === pos) {
        btn.classList.add("border-indigo-500", "bg-indigo-900/30", "text-indigo-300")
        btn.classList.remove("border-gray-700", "text-gray-400", "hover:border-gray-500", "hover:text-gray-200")
      } else {
        btn.classList.remove("border-indigo-500", "bg-indigo-900/30", "text-indigo-300")
        btn.classList.add("border-gray-700", "text-gray-400", "hover:border-gray-500", "hover:text-gray-200")
      }
    })
  }
}
