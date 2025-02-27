import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["modal", "successModal", "errorModal", "errorMessage", "textarea", "warning"];

    open() {
        this.modalTarget.classList.remove("hidden");
    }

    close() {
        this.modalTarget.classList.add("hidden");
    }

    closeSuccess() {
        this.successModalTarget.classList.add("hidden");
    }

    closeError() {
        this.errorModalTarget.classList.add("hidden");
    }

    submit(event) {
        event.preventDefault();
        const form = event.target;
        const data = new FormData(form);
        const submitButton = form.querySelector("button[type='submit']");

        submitButton.disabled = true;
        submitButton.textContent = "Отправка...";

        const payload = {
            report: {
                reportable_type: data.get("reportable_type"),
                reportable_id: data.get("reportable_id"),
                reason: data.get("reason") || "Другая причина",
                comment: data.get("complaint"),
            }
        };

        fetch(form.action, {
            method: "POST",
            body: JSON.stringify(payload),
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
            },
        })
            .then((response) => response.json().then((data) => ({ status: response.status, body: data })))
            .then(({ status, body }) => {
                if (status === 200) {
                    this.close();
                    this.successModalTarget.classList.remove("hidden");
                } else {
                    throw new Error(body.error || "Произошла ошибка при отправке жалобы");
                }
            })
            .catch((error) => {
                this.showError(error.message);
            })
            .finally(() => {
                submitButton.disabled = false;
                submitButton.textContent = "Отправить";
            });
    }

    showError(message) {
        this.errorMessageTarget.textContent = message;
        this.errorModalTarget.classList.remove("hidden");
    }
}
