import { Controller } from "stimulus";

export default class extends Controller {
    static targets = ["username", "fullLink"];

    connect() {
        this.updateLink();
        this.usernameTarget.addEventListener('input', () => this.updateLink());
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