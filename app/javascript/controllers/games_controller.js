import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "tagCheckbox", "tagMode", "toggleTagMode", "allGames", "myGames", "showAll", "showMine"]


    connect() {
        this.timeout = null
        this.displayAllGames();
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

    toggleTagMode(event) {
        this.tagModeTarget.value = this.toggleTagModeTarget.checked ? 'any' : 'all'
        this.search()
    }

    displayAllGames() {
        this.allGamesTarget.classList.remove("hidden");
        this.myGamesTarget.classList.add("hidden");

        this.showAllTarget.classList.add("font-bold", "text-gray-800");
        this.showMineTarget.classList.remove("font-bold", "text-gray-800");
    }

    displayMyGames() {
        this.myGamesTarget.classList.remove("hidden");
        this.allGamesTarget.classList.add("hidden");

        this.showMineTarget.classList.add("font-bold", "text-gray-800");
        this.showAllTarget.classList.remove("font-bold", "text-gray-800");
    }

    toggleGames(event) {
        if (event.currentTarget.dataset.gamesTarget === "showAll") {
            this.displayAllGames();
        } else if (event.currentTarget.dataset.gamesTarget === "showMine") {
            this.displayMyGames();
        }
    }
}