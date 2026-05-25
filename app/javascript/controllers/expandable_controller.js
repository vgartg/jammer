import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["text", "button"];
  static values = { collapsedClass: { type: String, default: "line-clamp-6" } };

  connect() {
    this.collapsed = true;
    requestAnimationFrame(() => this.revealButtonIfOverflowing());
  }

  toggle() {
    this.collapsed = !this.collapsed;
    this.textTarget.classList.toggle(this.collapsedClassValue, this.collapsed);
    this.buttonTarget.textContent = this.collapsed ? "Показать полностью" : "Свернуть";
  }

  revealButtonIfOverflowing() {
    if (!this.hasButtonTarget || !this.hasTextTarget) return;
    const overflowing = this.textTarget.scrollHeight > this.textTarget.clientHeight + 1;
    if (overflowing) this.buttonTarget.classList.remove("hidden");
  }
}
