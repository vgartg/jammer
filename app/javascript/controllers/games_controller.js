import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "tagCheckbox", "tagMode", "toggleTagMode", "resetButton",
        "coverInput", "coverPreviewImg", "coverText",
        "fileInput", "fileNameDisplay", "fileText",
        "checkbox", "label", "allGames", "myGames", "showAll", "showMine", "searchForm"]


    connect() {
        this.timeout = null
        this.displayAllGames();
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
            const label = checkbox.closest("[data-games-target='label']");
            const isChecked = checkbox.checked;

            if (isChecked) {
                url.searchParams.append('tag_ids[]', checkbox.value);

                label.classList.add("bg-indigo-500", "border-indigo-500", "text-white");
                label.classList.remove("bg-white", "border-gray-300", "text-gray-700");
            } else {
                label.classList.remove("bg-indigo-500", "border-indigo-500", "text-white");
                label.classList.add("border-gray-300", "text-gray-700");
            }
        });

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

    updateCoverPreview(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = (e) => {
                this.coverPreviewImgTarget.src = e.target.result;
                this.coverPreviewImgTarget.classList.remove('hidden');
                this.coverTextTarget.classList.remove('mt-0');
                this.coverTextTarget.classList.add('mt-4');
            };
            reader.readAsDataURL(file);
        }
    }

    updateFileName(event) {
        const file = event.target.files[0];
        if (file) {
            this.fileNameDisplayTarget.textContent = file.name;
            this.fileNameDisplayTarget.classList.remove('hidden');
            this.fileTextTarget.classList.remove('mt-0');
            this.fileTextTarget.classList.add('mt-4');
        }
    }

    toggleSelection(event) {
        const label = event.currentTarget;
        const checkbox = label.querySelector("[data-games-target='checkbox']");
        const isChecked = checkbox.checked;

        if (isChecked) {
            label.classList.remove("bg-indigo-500", "border-indigo-500", "text-white");
            label.classList.add("border-gray-300", "text-gray-700");
        } else {
            label.classList.add("bg-indigo-500", "border-indigo-500", "text-white");
            label.classList.remove("bg-white", "border-gray-300", "text-gray-700");
        }

        checkbox.checked = !isChecked;
    }

    displayAllGames() {
        this.allGamesTarget.classList.remove("hidden");
        this.searchFormTarget.classList.remove("hidden");
        this.myGamesTarget.classList.add("hidden");

        this.showAllTarget.classList.add("font-bold", "text-gray-800");
        this.showMineTarget.classList.remove("font-bold", "text-gray-800");
    }

    displayMyGames() {
        this.myGamesTarget.classList.remove("hidden");
        this.allGamesTarget.classList.add("hidden");
        this.searchFormTarget.classList.add("hidden");

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