import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static targets = ['modal', 'cancelButton']

    connect() {
        this.modalTarget.classList.add('hidden')
    }

    open() {
        this.modalTarget.classList.remove('hidden')
    }

    close() {
        this.modalTarget.classList.add('hidden')
    }
}
