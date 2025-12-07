import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["avatarInput", "avatarImage", "editField", "displayInfo", "newValue", "oldValue", "avatarLabel"];
    // , "gameItem", "toggleButton"

    connect() {
        this.avatarLabelTarget.addEventListener('click', (event) => {
            event.preventDefault();
            this.avatarInputTarget.click();
        });

        this.avatarInputTarget.addEventListener('change', () => {
            const file = this.avatarInputTarget.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = (e) => {
                    this.avatarImageTarget.src = e.target.result;
                };
                reader.readAsDataURL(file);
            }
        });

        this.updateButtonText();
    }

    toggleEditField(event) {
        const field = event.target.dataset.field;
        const editField = this.element.querySelector(`#edit-field-${field}`);
        const displayInfo = this.element.querySelector(`#display-info-${field}`);
        const newValue = this.element.querySelector(`#new-${field}`);
        const oldValue = this.element.querySelector(`#old-${field}`);
        const input = this.element.querySelector(`#${field}_input`);

        if (editField.classList.contains('hidden')) {
            editField.classList.remove('hidden');
            displayInfo.classList.add('hidden');
            // Temporarily show new value
            newValue.textContent = input.value;
        } else {
            editField.classList.add('hidden');
            displayInfo.classList.remove('hidden');
        }

        if (event.target.dataset.action === "save") {
            newValue.classList.remove('hidden');
            oldValue.classList.add('hidden');
        }
    }

    updateValue(event) {
        const field = event.target.dataset.field;
        const newValue = this.element.querySelector(`#new-${field}`);
        const value = event.target.value.trim() === '' ? 'Информации нет' : event.target.value;

        newValue.textContent = value;

        let hiddenInput = this.element.querySelector(`input[name='user[${field}]']`);
        if (!hiddenInput) {
            hiddenInput = document.createElement('input');
            hiddenInput.type = 'hidden';
            hiddenInput.name = `user[${field}]`;
            this.element.querySelector('form').appendChild(hiddenInput);
        }
        hiddenInput.value = value;
    }

    // На будущее (смена <script> под stimulus из _profile.html.erb)

    // toggleGames() {
    //     const hiddenGames = this.gameItemTargets.filter(item => item.classList.contains('hidden'));
    //     const isHidden = hiddenGames.length > 0;
    //
    //     if (isHidden) {
    //         hiddenGames.forEach(game => {
    //             game.classList.remove('hidden');
    //         });
    //         this.toggleButtonTarget.innerText = 'Скрыть игры';
    //     } else {
    //         this.gameItemTargets.forEach((game, index) => {
    //             if (index >= 8) {
    //                 game.classList.add('hidden');
    //             }
    //         });
    //         this.toggleButtonTarget.innerText = 'Показать все игры';
    //     }
    // }
    //
    // updateButtonText() {
    //     const hiddenGames = this.gameItemTargets.filter(item => item.classList.contains('hidden'));
    //     this.toggleButtonTarget.innerText = hiddenGames.length > 0 ? 'Показать все игры' : 'Скрыть игры';
    // }
}