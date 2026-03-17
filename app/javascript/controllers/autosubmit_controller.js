import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { delay: { type: Number, default: 400 } }

    connect() {
        this.timeout = null
    }

    submit(event) {
        clearTimeout(this.timeout)

        const input = event.target
        const query = input.value.trim()

        // ❗ Не искать если меньше 2 символов
        if (query.length < 2) {
            document.getElementById("jury_search_results").innerHTML =
                '<div class="mt-3 text-sm text-gray-500">Введите минимум 2 символа</div>'
            return
        }

        this.timeout = setTimeout(() => {
            const form = this.element
            const url = new URL(form.action)
            const params = new URLSearchParams(new FormData(form))
            url.search = params.toString()

            fetch(url, {
                headers: { "Accept": "text/html" }
            })
                .then(response => response.text())
                .then(html => {
                    document.getElementById("jury_search_results").innerHTML = html
                })
        }, this.delayValue)
    }

    disconnect() {
        clearTimeout(this.timeout)
    }
}