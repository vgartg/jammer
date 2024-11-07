import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "input", "tagCheckbox", "tagMode", "toggleTagMode",
        "coverInput", "coverPreviewImg", "coverText",
        "logoInput", "logoPreviewImg", "logoText"
    ]

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

    // Handle cover input change
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

    // Handle logo input change
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

    // Utility to adjust the text margin
    updateTextMargin(textTarget) {
        if (textTarget.classList.contains('mt-0')) {
            textTarget.classList.remove('mt-0')
            textTarget.classList.add('mt-4')
        }
    }
}
