import { Controller } from "stimulus";
import flatpickr from 'flatpickr';

export default class extends Controller {
    static targets = ["username", "fullLink", "section"];

    connect() {
        this.updateLink();
        this.usernameTarget.addEventListener('input', () => this.updateLink());

        this.sectionTargets.forEach((section, index) => {
            if (index !== 0) {
                section.classList.add('hidden');
            }
        });

        this.formatPhoneNumber();
        this.initFlatpickr();
    }

    close_notice() {
        this.element.remove();
    }

    formatPhoneNumber() {
        let phoneInput = this.element.querySelector('#phone_number');

        if (phoneInput) {
            phoneInput.addEventListener('input', (e) => {
                let x = e.target.value.replace(/\D/g, '');
                let formattedValue = '+7 (';

                if (x.length > 1) {
                    formattedValue += x.substring(1, 4);
                }
                if (x.length > 4) {
                    formattedValue += ') ' + x.substring(4, 7);
                }
                if (x.length > 7) {
                    formattedValue += '-' + x.substring(7, 9);
                }
                if (x.length > 9) {
                    formattedValue += '-' + x.substring(9, 11);
                }

                e.target.value = formattedValue;
            });
        }
    }

    toggleSection(event) {
        event.preventDefault();

        const targetSection = event.currentTarget.getAttribute("data-target");
        const SetMenuItems = document.querySelectorAll('.section.divide-y.set-menuitem');
        const ChangeSettBut = event.currentTarget;

        SetMenuItems.forEach(section => {
            if (section.id === targetSection) {
                ChangeSettBut.classList.add('text-indigo-400');
                section.classList.remove('hidden');
            } else {
                const otherButtons = document.querySelectorAll('.change-set-button:not([data-target="' + targetSection + '"])');
                otherButtons.forEach(button => {
                    button.classList.remove('text-indigo-400');
                });
                section.classList.add('hidden');
            }
        });
    }

    updateLink() {
        let username = this.usernameTarget.value.trim();

        username = username.replace(/[^a-zA-Z0-9-]/g, '');

        const validUsername = /^[a-zA-Z0-9-]*$/.test(username);

        this.usernameTarget.value = username;

        if (validUsername && username !== '') {
            this.fullLinkTarget.textContent = `https://${username}.jammer.ru/`;
        } else {
            this.fullLinkTarget.textContent = `https://username.jammer.ru/`;
        }
    }

    initFlatpickr() {
        flatpickr('.flatpickr', {
            dateFormat: 'Y-m-d',
            theme: 'dark',
        });
    }
}