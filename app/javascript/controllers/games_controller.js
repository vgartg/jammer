import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "tagCheckbox", "tagMode", "toggleTagMode", "resetButton",
        "coverPreviewImg", "coverText", "fileNameDisplay", "fileText", "logoPreviewImg", "logoText"]


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

    updateLogoPreview(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();

            reader.onload = (e) => {
                this.logoPreviewImgTarget.src = e.target.result;
                this.logoPreviewImgTarget.classList.remove('hidden');
                this.logoTextTarget.classList.remove('mt-0');
                this.logoTextTarget.classList.add('mt-4');
            };

            reader.readAsDataURL(file);
        }
    }
}