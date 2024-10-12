import { Controller } from "stimulus"

export default class extends Controller {
    static targets = ["profileMenu", "grayBlock", "leftBlock", "menuItem", "content"];

    connect() {
        // const url = new URL(window.location.href);
        // const hash = url.hash.substring(1); // Удаляем '#'
        // const menuItemTarget = this.menuItemTarget(); // Предполагаем, что у вас есть метод,
        // // который возвращает элемент меню с соответствующим data-content-id
        //
        // // Определяем активный сегмент хеша
        // const activeContentId = hash || 'dashboard'; // Если хеш отсутствует, используем 'dashboard'
        // // по умолчанию
        //
        // // Скрыть все контенты
        // const allContents = document.querySelectorAll('.content');
        // allContents.forEach(content => {
        //     content.classList.add('hidden');
        // });
        //
        // // Показать и подсвечить выбранный контент
        // const selectedContent = document.getElementById(activeContentId);
        // if (selectedContent) {
        //     selectedContent.classList.remove('hidden');
        //     this.highlightMenuItem(menuItemTarget); // Метод для подсвечивания выбранного элемента меню
        // }
        //
        // if (hash) {
        //     this.dashboardChanger({ target: menuItemTarget }); // Вызываем событие,
        //     // передавая menuItemTarget в качестве аргумента
        // }
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

        const selectedContentId = menuItem.getAttribute('data-content-id');
        //const url = new URL(window.location.href);
        // url.hash = selectedContentId;
        // window.history.pushState({}, '', url.href);

        if (selectedContentId !== 'zaglushka') {
            window.location = '/' + selectedContentId;
        }

        if (!menuItem) return;

        const menuItems = document.querySelectorAll('.group.flex.gap-x-3.rounded-md.p-2.text-sm.font-semibold.leading-6.text-gray-400');
        menuItems.forEach(item => {
            item.classList.remove('selected', 'bg-gray-800');
            const link = item.querySelector('a');
            if (link) {
                link.classList.remove('text-white');
            }
        });

        menuItem.classList.add('selected', 'bg-gray-800');
        menuItem.querySelector('a').classList.add('text-white');

        const allContents = document.querySelectorAll('.content');
        allContents.forEach(content => {
            content.classList.add('hidden');
        });

        const selectedContent= document.getElementById(selectedContentId);
        if (selectedContent) {
            selectedContent.classList.remove('hidden');
        }
    }
}