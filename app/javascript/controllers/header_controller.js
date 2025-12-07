import {Controller} from "stimulus"

export default class extends Controller {
    OpenHeaderMenu() {
        const openButton = this.element.querySelector('#open-header-button');
        const mobileMenu = this.element.querySelector('#mobile-header-block');
        mobileMenu.classList.remove('hidden');
    }

    CloseHeaderMenu() {
        const closeButton = this.element.querySelector('#close-header-button');
        const mobileMenu = this.element.querySelector('#mobile-header-block');
        mobileMenu.classList.add('hidden');
    }

    toggleLanguageMenu() {
        const languageMenu = this.element.querySelector('#language_menu');
        if (languageMenu.classList.contains('hidden')) {
            languageMenu.classList.remove('hidden');
        } else {
            languageMenu.classList.add('hidden');
        }
    }
}