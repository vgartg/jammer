import { Controller } from "stimulus";
import Rails from "@rails/ujs";

export default class extends Controller {
    static targets = ["notificationsMenu"];

    toggleNotificationsMenu() {
        const notificationsMenu = this.notificationsMenuTarget;
        notificationsMenu.classList.toggle('hidden');

        Rails.ajax({
            type: 'patch',
            url: '/notifications/mark_as_read',
            dataType: 'json',
            success: (data) => {
                this.updateNotifications(data);
            },
            error: function(error) { }
        });
    }

    updateNotifications(data) {
        const notificationsList = document.getElementById('dashboard_notifications_menu');

        data.forEach((notification) => {
            const actionTranslation = this.actionsTranslations[notification.action];
            if (actionTranslation) {
                notification.actionTranslation = actionTranslation;
            }
        });
    }
}
