import { Controller } from "stimulus"

export default class extends Controller {
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
}