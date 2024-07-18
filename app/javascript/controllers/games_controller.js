import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "input" ]


    connect() {
        this.timeout = null
    }

    search() {
        clearTimeout(this.timeout)

        this.timeout = setTimeout(() => {
            this.performSearch()
        }, 200)
    }

    performSearch() {
        const url = new URL(window.location.href)
        url.searchParams.set('search', this.inputTarget.value)
            fetch(url.toString(), {
            headers: {
                "Accept": "text/vnd.turbo-stream.html"
            }
        })
            .then(response => {
                if (response.ok){
                    return response.text();
                }
               else{
                   throw new Error("Can't load results")
                }
            })
            .then(html => {
                Turbo.renderStreamMessage(html)
            })
                .catch()
    }
}