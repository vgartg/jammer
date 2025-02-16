import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["reason", "duration", "submit"];

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
            alert("Необходимо указать причину заморозки.");
            return;
        }

        this.submitTarget.setAttribute("disabled", "true");
        this.submitTarget.textContent = "Замораживание...";

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
            alert("Ошибка при заморозке пользователя.");
            this.submitTarget.removeAttribute("disabled");
            this.submitTarget.textContent = "Заморозить";
        }
    }
}
