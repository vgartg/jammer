import { Controller } from "stimulus";

export default class extends Controller {
    static targets = ["username", "fullLink"];

    connect() {
        this.updateLink();
        this.usernameTarget.addEventListener('input', () => this.updateLink());

        this.formatPhoneNumber();
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

    updateLink() {
        let username = this.usernameTarget.value.trim(); // Удаляем начальные и конечные пробелы

        // Очищаем ввод от недопустимых символов
        username = username.replace(/[^a-zA-Z0-9-]/g, '');

        // Проверяем, что username соответствует шаблону
        const validUsername = /^[a-zA-Z0-9-]*$/.test(username);

        // Устанавливаем значение поля ввода
        this.usernameTarget.value = username;

        if (validUsername && username !== '') {
            this.fullLinkTarget.textContent = `https://${username}.jammer.ru/`;
        } else {
            this.fullLinkTarget.textContent = `https://username.jammer.ru/`;
        }
    }
}