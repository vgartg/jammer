import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static targets = ['modal', 'cancelButton', 'errorMessage']

    connect() {
        this.modalTarget.classList.add('hidden')
    }

    open() {
        this.modalTarget.classList.remove('hidden')
        this.errorMessageTarget.textContent = ''
    }

    close() {
        this.modalTarget.classList.add('hidden')
    }

    async submitForm(event) {
        event.preventDefault()

        const formData = new FormData(event.target)
        const response = await fetch(event.target.action, {
            method: 'DELETE',
            body: formData,
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'Accept': 'application/json'
            }
        })

        const data = await response.json()

        if (data.success) {
            this.close()
            window.location.href = '/register'
        } else {
            this.errorMessageTarget.textContent = data.error
        }
    }
}
