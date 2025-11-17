import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["text"];

  toggle(event) {
    if (event.target.tagName !== "A") {
      this.textTarget.classList.toggle("truncate");
      this.textTarget.classList.toggle("break-all");
    }
  }
}
