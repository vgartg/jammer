import { Controller } from "stimulus"

export default class extends Controller {
    static targets = ["profileMenu", "grayBlock", "leftBlock", "menuItem", "content"];

    connect() {
        let selectedContentId = window.location.pathname.split('/')[1];
        if (selectedContentId) {
            let cur_items = document.querySelectorAll('#' + selectedContentId);

            cur_items.forEach(content => {
                content.classList.add('bg-gray-800');
                content.querySelector('a').classList.add('text-white');
            });
        }
    }

    menuItemTarget() {
        // Находим элемент меню с соответствующим data-content-id
        const menuItems = document.querySelectorAll('.group.flex.gap-x-3.rounded-md.p-2.text-sm.font-semibold.leading-6.text-gray-400');
        for (const item of menuItems) {
            if (item.getAttribute('data-content-id') === window.location.hash.substring(1)) {
                return item;
            }
        }
        return null;
    }

    highlightMenuItem(menuItem) {
        // Добавляем классы, чтобы подсветить выбранный элемент меню
        menuItem.classList.add('selected', 'bg-gray-800');
        menuItem.querySelector('a').classList.add('text-white');
    }

    toggleProfileMenu() {
        const profileMenu = this.element.querySelector('#dashboard_profile_menu');
        if (profileMenu.classList.contains('hidden')) {
            profileMenu.classList.remove('hidden');
        } else {
            profileMenu.classList.add('hidden');
        }
    }

    openMobileMenu() {
        const grayBlock = document.getElementById('dashboard_gray_opacity_block');
        const leftBlock = document.getElementById('dashboard_left_mobile_block');

        grayBlock.classList.remove('opacity-0');
        leftBlock.classList.remove('-translate-x-full');
        grayBlock.classList.remove('hidden');
        grayBlock.classList.add('opacity-100');
        leftBlock.classList.add('translate-x-0');
    }

    closeMobileMenu() {
        const grayBlock = document.getElementById('dashboard_gray_opacity_block');
        const leftBlock = document.getElementById('dashboard_left_mobile_block');

        grayBlock.classList.remove('opacity-100');
        leftBlock.classList.remove('translate-x-0');
        grayBlock.classList.add('opacity-0');
        leftBlock.classList.add('-translate-x-full');
        grayBlock.classList.add('hidden');
    }

    dashboardChanger(event) {
        const menuItem = event.target.closest('li');

        if (!menuItem) return;

        const selectedContentId = menuItem.getAttribute('data-content-id');

        if (selectedContentId !== 'zaglushka') {
            window.location = '/' + selectedContentId;
        }
    }
}