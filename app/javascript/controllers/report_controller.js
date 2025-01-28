import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["modal", "successModal"];

    open() {
        this.modalTarget.classList.remove("hidden");
    }

    close() {
        this.modalTarget.classList.add("hidden");
    }

    closeSuccess() {
        this.successModalTarget.classList.add("hidden");
    }

    submit(event) {
        event.preventDefault();
        const form = event.target;
        const data = new FormData(form);
        const submitButton = form.querySelector("button[type='submit']");
        submitButton.disabled = true;
        submitButton.textContent = "Отправка...";
        fetch(form.action, {
            method: "POST",
            body: data,
            headers: {
                "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
            },
        })
            .then((response) => {
                if (!response.ok) {
                    throw new Error("Не удалось отправить жалобу");
                }
                return response.json();
            })
            .then(() => {
                this.close();
                this.successModalTarget.classList.remove("hidden");
            })
            .catch(() => {
                alert("Произошла ошибка при отправке жалобы!");
            })
            .finally(() => {
                submitButton.disabled = false;
                submitButton.textContent = "Отправить";
            });
    }
}
