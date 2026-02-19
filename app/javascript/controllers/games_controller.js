import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "input", "tagCheckbox", "tagMode", "toggleTagMode", "resetButton",
        "coverPreviewImg", "coverText",
        "fileNameDisplay", "fileText",
        "checkbox", "label",
        "allGames", "myGames", "showAll", "showMine", "searchForm"
    ]

    connect() {
        this.timeout = null

        // если это showcase — включаем "Все игры"
        if (this.hasAllGamesTarget && this.hasMyGamesTarget) {
            this.displayAllGames()
        }
    }

    toggleGames(event) {
        const view = event.currentTarget.dataset.view
        if (view === "all") this.displayAllGames()
        if (view === "mine") this.displayMyGames()
    }

    displayAllGames() {
        if (!this.hasAllGamesTarget || !this.hasMyGamesTarget) return

        this.allGamesTarget.classList.remove("hidden")
        this.myGamesTarget.classList.add("hidden")

        if (this.hasSearchFormTarget) this.searchFormTarget.classList.remove("hidden")
        if (this.hasShowAllTarget) this.showAllTarget.classList.add("font-bold", "text-gray-800")
        if (this.hasShowMineTarget) this.showMineTarget.classList.remove("font-bold", "text-gray-800")
    }

    displayMyGames() {
        if (!this.hasAllGamesTarget || !this.hasMyGamesTarget) return

        this.myGamesTarget.classList.remove("hidden")
        this.allGamesTarget.classList.add("hidden")

        if (this.hasSearchFormTarget) this.searchFormTarget.classList.add("hidden")
        if (this.hasShowMineTarget) this.showMineTarget.classList.add("font-bold", "text-gray-800")
        if (this.hasShowAllTarget) this.showAllTarget.classList.remove("font-bold", "text-gray-800")
    }

    search() {
        if (!this.hasInputTarget) return

        clearTimeout(this.timeout)
        this.timeout = setTimeout(() => this.performSearch(), 200)

        if (this.hasResetButtonTarget && this.hasTagCheckboxTarget && this.hasToggleTagModeTarget) {
            this.updateResetButtonVisibility()
        }
    }

    performSearch() {
        const url = new URL(window.location.href)
        url.searchParams.set("search", this.inputTarget.value)
        url.searchParams.delete("tag_ids[]")

        if (this.hasTagCheckboxTarget) {
            this.tagCheckboxTargets.forEach((checkbox) => {
                const label = checkbox.closest("[data-games-target='label']")
                if (!label) return

                if (checkbox.checked) {
                    url.searchParams.append("tag_ids[]", checkbox.value)
                    label.classList.add("bg-indigo-500", "border-indigo-500", "text-white")
                    label.classList.remove("bg-white", "border-gray-300", "text-gray-700")
                } else {
                    label.classList.remove("bg-indigo-500", "border-indigo-500", "text-white")
                    label.classList.add("border-gray-300", "text-gray-700")
                }
            })
        }

        if (this.hasTagModeTarget) url.searchParams.set("tag_mode", this.tagModeTarget.value)

        fetch(url.toString(), { headers: { Accept: "text/vnd.turbo-stream.html" } })
            .then((r) => (r.ok ? r.text() : Promise.reject()))
            .then((html) => Turbo.renderStreamMessage(html))
            .catch(() => {})
    }

    toggleTagMode() {
        if (!this.hasTagModeTarget || !this.hasToggleTagModeTarget) return
        this.tagModeTarget.value = this.toggleTagModeTarget.checked ? "any" : "all"
        this.search()
    }

    resetTags() {
        if (!this.hasTagCheckboxTarget || !this.hasToggleTagModeTarget || !this.hasTagModeTarget) return

        this.tagCheckboxTargets.forEach((checkbox) => (checkbox.checked = false))
        this.toggleTagModeTarget.checked = false
        this.tagModeTarget.value = "all"
        this.search()
    }

    updateResetButtonVisibility() {
        const anyTagSelected = this.tagCheckboxTargets.some((c) => c.checked)
        const isTagModeEnabled = this.toggleTagModeTarget.checked

        if (anyTagSelected || isTagModeEnabled) this.resetButtonTarget.classList.remove("hidden")
        else this.resetButtonTarget.classList.add("hidden")
    }

    updateCoverPreview(event) {
        if (!this.hasCoverPreviewImgTarget || !this.hasCoverTextTarget) return

        const file = event.target.files[0]
        if (!file) return

        const reader = new FileReader()
        reader.onload = (e) => {
            this.coverPreviewImgTarget.src = e.target.result
            this.coverPreviewImgTarget.classList.remove("hidden")
            this.coverTextTarget.classList.remove("mt-0")
            this.coverTextTarget.classList.add("mt-4")
        }
        reader.readAsDataURL(file)
    }

    updateFileName(event) {
        if (!this.hasFileNameDisplayTarget || !this.hasFileTextTarget) return

        const file = event.target.files[0]
        if (!file) return

        this.fileNameDisplayTarget.textContent = file.name
        this.fileNameDisplayTarget.classList.remove("hidden")
        this.fileTextTarget.classList.remove("mt-0")
        this.fileTextTarget.classList.add("mt-4")
    }

    toggleSelection(event) {
        const label = event.currentTarget
        const checkbox = label.querySelector("[data-games-target='checkbox']")
        if (!checkbox) return

        const isChecked = checkbox.checked
        if (isChecked) {
            label.classList.remove("bg-indigo-500", "border-indigo-500", "text-white")
            label.classList.add("border-gray-300", "text-gray-700")
        } else {
            label.classList.add("bg-indigo-500", "border-indigo-500", "text-white")
            label.classList.remove("bg-white", "border-gray-300", "text-gray-700")
        }
        checkbox.checked = !isChecked
    }
}
