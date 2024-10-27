import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "tagCheckbox", "tagMode", "toggleTagMode", "resetButton"]


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

    toggleTagMode(event) {
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
}