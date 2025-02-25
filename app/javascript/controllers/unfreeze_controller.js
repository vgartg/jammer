import { Controller } from "stimulus";

export default class extends Controller {
    static targets = ["submit"];

    async unfreezeUser() {
        const response = await fetch(`/admin/users/${this.element.dataset.userId}/unfreeze`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
            },
        });

        if (response.ok) {
            location.reload();
        } else {
            alert("Ошибка при разморозке пользователя.");
        }
    }
}
