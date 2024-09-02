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
            success: (data) => {
                console.log('Notifications marked as read:', data);
                this.updateNotifications(data); // Обновляем уведомления на странице
            },
            error: function(error) {
                console.error('Error marking notifications as read:', error);
            }
        });
    }

    updateNotifications(data) {
        const notificationsList = document.getElementById('dashboard_notifications_menu');

        if (notificationsList) {
            if (data.length > 0) {
                // Преобразуем данные в HTML для новых уведомлений
                const newNotificationsHTML = data.map(notification => `
                <div class="flex items-start px-4 py-3 border-b border-gray-200">
                    <div class="mr-3">
                        ${notification.actor.avatar ? `<img src="${notification.actor.avatar}" alt="Profile Picture" class="h-8 w-8 text-gray-400">` : `<img src="https://via.placeholder.com/150" alt="Profile Picture" class="h-8 w-8 text-gray-400">`}
                    </div>
                    <div>
                        <p class="text-sm font-medium text-gray-900">
                            ${notification.actor.name} ${notification.action}
                        </p>
                    </div>
                </div>`).join('');

                // Добавляем новые уведомления в начало списка
                notificationsList.insertAdjacentHTML('afterbegin', newNotificationsHTML);
            }
        }

        // Обновляем счетчик уведомлений
        const notificationsCount = data.length;
        const notificationsBadge = document.querySelector('.bg-red-500');
        if (notificationsBadge) {
            notificationsBadge.textContent = notificationsCount;
            notificationsBadge.style.display = notificationsCount > 0 ? 'inline-block' : 'none';
        }
    }
}
