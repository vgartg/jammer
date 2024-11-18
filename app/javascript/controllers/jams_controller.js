import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "input", "tagCheckbox", "tagMode", "toggleTagMode", "resetButton",
        "coverInput", "coverPreviewImg", "coverText",
        "logoInput", "logoPreviewImg", "logoText"
    ]

    connect() {
        this.timeout = null
        this.updateResetButtonVisibility();
    }

    search() {
        clearTimeout(this.timeout)
        this.timeout = setTimeout(() => {
            this.performSearch()
        }, 200)
        this.updateResetButtonVisibility();
    }

    performSearch() {
        const url = new URL(window.location.href)
        url.searchParams.set('search', this.inputTarget.value)
        url.searchParams.delete('tag_ids[]')

        this.tagCheckboxTargets.forEach(checkbox => {
            if (checkbox.checked) {
                url.searchParams.append('tag_ids[]', checkbox.value)
            }
        })

        url.searchParams.set('tag_mode', this.tagModeTarget.value)

        fetch(url.toString(), {
            headers: {
                "Accept": "text/vnd.turbo-stream.html"
            }
        })
            .then(response => {
                if (response.ok) {
                    return response.text();
                } else {
                    throw new Error("Can't load results")
                }
            })
            .then(html => {
                Turbo.renderStreamMessage(html)
            })
            .catch()
    }

    toggleTagMode() {
        this.tagModeTarget.value = this.toggleTagModeTarget.checked ? 'any' : 'all'
        this.search()
    }

    resetTags() {
        this.tagCheckboxTargets.forEach(checkbox => {
            checkbox.checked = false;
        });
        this.toggleTagModeTarget.checked = false;
        this.tagModeTarget.value = 'all';
        this.search();
    }
    updateResetButtonVisibility() {
        const anyTagSelected = this.tagCheckboxTargets.some(checkbox => checkbox.checked);
        const isTagModeEnabled = this.toggleTagModeTarget.checked;
        if (anyTagSelected || isTagModeEnabled) {
            this.resetButtonTarget.classList.remove("hidden");
        } else {
            this.resetButtonTarget.classList.add("hidden");
        }
    }

    updateCoverPreview(event) {
        const file = event.target.files[0]
        if (file) {
            const reader = new FileReader()
            reader.onload = (e) => {
                this.coverPreviewImgTarget.src = e.target.result
                this.coverPreviewImgTarget.classList.remove('hidden')
                this.updateTextMargin(this.coverTextTarget)
            }
            reader.readAsDataURL(file)
        }
    }

    updateLogoPreview(event) {
        const file = event.target.files[0]
        if (file) {
            const reader = new FileReader()
            reader.onload = (e) => {
                this.logoPreviewImgTarget.src = e.target.result
                this.logoPreviewImgTarget.classList.remove('hidden')
                this.updateTextMargin(this.logoTextTarget)
            }
            reader.readAsDataURL(file)
        }
    }

    updateTextMargin(textTarget) {
        if (textTarget.classList.contains('mt-0')) {
            textTarget.classList.remove('mt-0')
            textTarget.classList.add('mt-4')
        }
    }

    validateStartDates() {
        const startDateInput = this.element.querySelector('#start_date');
        const deadlineInput = this.element.querySelector('#deadline');
        const errorMessageElement = document.getElementById('start_date-error-message');

        const startDate = new Date(startDateInput.value);

        if (isNaN(startDate.getTime()) || startDate.getFullYear() < 2000) {
            errorMessageElement.textContent = 'Пожалуйста, введите корректные даты';
        }
        else { errorMessageElement.textContent = ''; }

        if (this._checkErrorMassage()){
            this._enableSubmitButton();
        } else this._disableSubmitButton();

        if (deadlineInput.value === '') return;
        this.validateDeadline();
    }

    validateDeadline() {
        const startDateInput = this.element.querySelector('#start_date');
        const deadlineInput = this.element.querySelector('#deadline');
        const endDateInput = this.element.querySelector('#end_date');
        const errorMessageElement = document.getElementById('deadline-error-message');

        const startDate = new Date(startDateInput.value);
        const deadline = new Date(deadlineInput.value);

        if (isNaN(deadline.getTime()) || deadline.getFullYear() < 2000) {
            errorMessageElement.textContent = 'Пожалуйста, введите корректные даты';}
        else if (deadline < startDate) {
            errorMessageElement.textContent = 'Дата сдачи работ не может быть раньше даты начала';
        } else { errorMessageElement.textContent = ''; }

        if (this._checkErrorMassage()){
            this._enableSubmitButton();
        } else this._disableSubmitButton();

        if (endDateInput.value === '') return;
        this.validateEndDates();
    }

    validateEndDates() {
        const deadlineInput = this.element.querySelector('#deadline');
        const endDateInput = this.element.querySelector('#end_date');
        const errorMessageElement = document.getElementById('end_date-error-message');

        const deadline = new Date(deadlineInput.value);
        const endDate = new Date(endDateInput.value);

        if (isNaN(endDate.getTime()) || endDate.getFullYear() < 2000) {
            errorMessageElement.textContent = 'Пожалуйста, введите корректные даты';}
        else if(endDate < deadline) {
            errorMessageElement.textContent = 'Дата окончания джема не может быть раньше даты сдачи работ';
        } else { errorMessageElement.textContent = ''; }

        if (this._checkErrorMassage()){
            this._enableSubmitButton();
        } else this._disableSubmitButton();
    }

    _checkErrorMassage(){
        const errorMessageStartDate = document.getElementById('start_date-error-message');
        const errorMessageDeadline = document.getElementById('deadline-error-message');
        const errorMessageEndDate = document.getElementById('end_date-error-message');

        return errorMessageStartDate.textContent === '' &&
            errorMessageDeadline.textContent === '' &&
            errorMessageEndDate.textContent === '';
    }

    _enableSubmitButton() {
        const submitButton = document.getElementById('submit-button');

        submitButton.disabled = false;

        submitButton.classList.remove('bg-gray-400', 'cursor-not-allowed');
        submitButton.classList.add('bg-indigo-600', 'hover:bg-indigo-700');
    }

    _disableSubmitButton() {
        const submitButton = document.getElementById('submit-button');

        submitButton.disabled = true;

        submitButton.classList.remove('bg-indigo-600', 'hover:bg-indigo-700');
        submitButton.classList.add('bg-gray-400', 'cursor-not-allowed');
    }
}
