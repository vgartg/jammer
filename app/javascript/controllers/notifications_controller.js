import { Controller } from "stimulus";
import Rails from "@rails/ujs";

export default class extends Controller {
    static targets = ["notificationsMenu", "badge"];
    static values = { markAsReadUrl: String };

    toggleNotificationsMenu() {
        const notificationsMenu = this.notificationsMenuTarget;
        notificationsMenu.classList.toggle('hidden');

        Rails.ajax({
            type: 'patch',
            url: this.markAsReadUrlValue,
            dataType: 'json',
            success: () => {
                if (this.hasBadgeTarget) {
                    this.badgeTarget.remove();
                }
            },
            error: function(error) { }
        });
    }
}
