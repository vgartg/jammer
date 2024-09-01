import { Controller } from "stimulus";
import Rails from "@rails/ujs";

export default class extends Controller {
    static targets = ["notificationsMenu"];

    toggleNotificationsMenu() {
        const notificationsMenu = this.notificationsMenuTarget;
        notificationsMenu.classList.toggle('hidden');

        // Mark notifications as read via AJAX
        Rails.ajax({
            type: 'patch',
            url: '/notifications/mark_as_read',
            dataType: 'json',
            success: function(response) {
                console.log('Notifications marked as read');
            },
            error: function(error) {
                console.error('Error marking notifications as read:', error);
            }
        });
    }
}
