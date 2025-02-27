import { Controller } from "stimulus";

export default class extends Controller {
    static targets = ["modal"];

    connect() {
        if (this.data.get("isFrozen") === "true") {
            this.open();
        }
    }

    open() {
        this.modalTarget.classList.remove("hidden");
    }

    close() {
        this.modalTarget.classList.add("hidden");
    }
}
