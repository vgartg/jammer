import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["reason", "duration", "submit"];
    static values = {
        reasonRequired: String,
        freezing: String,
        error: String,
        freezeLabel: String
    };

    connect() {
        this.toggleButton();
    }

    open() {
        document.getElementById("freeze-modal").classList.remove("hidden");
    }

    close() {
        document.getElementById("freeze-modal").classList.add("hidden");
    }

    checkInput() {
        this.toggleButton();
    }

    toggleButton() {
        if (this.reasonTarget.value.trim() !== "") {
            this.submitTarget.removeAttribute("disabled");
            this.submitTarget.classList.remove("opacity-50", "cursor-not-allowed");
        } else {
            this.submitTarget.setAttribute("disabled", "true");
            this.submitTarget.classList.add("opacity-50", "cursor-not-allowed");
        }
    }

    async submit() {
        const reason = this.reasonTarget.value.trim();
        const duration = this.durationTarget.value;

        if (!reason) {
            alert(this.reasonRequiredValue);
            return;
        }

        this.submitTarget.setAttribute("disabled", "true");
        this.submitTarget.textContent = this.freezingValue;

        const response = await fetch(`/admin/users/${this.element.dataset.userId}/freeze`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
            },
            body: JSON.stringify({ reason, duration })
        });

        if (response.ok) {
            location.reload();
        } else {
            alert(this.errorValue);
            this.submitTarget.removeAttribute("disabled");
            this.submitTarget.textContent = this.freezeLabelValue;
        }
    }
}
