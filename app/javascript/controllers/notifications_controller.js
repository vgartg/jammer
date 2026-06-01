import { Controller } from "stimulus";
import Rails from "@rails/ujs";

export default class extends Controller {
    static targets = ["notificationsMenu", "badge"];
    static values = { markAsReadUrl: String };

    openNotification(event) {
        if (event.target.closest('button') || event.target.closest('form') || event.target.closest('a')) return;
        const url = event.currentTarget.dataset.href;
        if (url) window.location.href = url;
    }

    toggleNotificationsMenu() {
        const notificationsMenu = this.notificationsMenuTarget;
        const isOpening = notificationsMenu.classList.contains('hidden');
        notificationsMenu.classList.toggle('hidden');

        if (!isOpening || !this.hasBadgeTarget) return;

        Rails.ajax({
            type: 'patch',
            url: this.markAsReadUrlValue,
            dataType: 'json',
            success: () => {
                if (this.hasBadgeTarget) {
                    this.badgeTarget.remove();
                }
            },
            error: (error) => {
                console.error('Failed to mark notifications as read:', error);
            }
        });
    }
}
