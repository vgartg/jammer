import { Controller } from "stimulus"

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
}