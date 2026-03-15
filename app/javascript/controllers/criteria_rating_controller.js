import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["markInput"]

    connect() {
        // Подсветить звезды для уже существующих оценок + посчитать общий
        this.markInputTargets.forEach((input) => {
            const criterionId = input.dataset.criterionId
            const rating = parseFloat(input.value || "0")
            this.paintStars(criterionId, rating)
        })
        this.recalcOverall()
    }

    hover(event) {
        const rating = parseInt(event.currentTarget.dataset.rating, 10)
        const criterionId = event.currentTarget.dataset.criterionId
        this.paintStars(criterionId, rating, true)
    }

    leave(event) {
        const criterionId = event.currentTarget.dataset.criterionId
        const input = this.findMarkInput(criterionId)
        const rating = parseFloat(input.value || "0")
        this.paintStars(criterionId, rating)
    }

    setRating(event) {
        const rating = parseInt(event.currentTarget.dataset.rating, 10)
        const criterionId = event.currentTarget.dataset.criterionId

        const input = this.findMarkInput(criterionId)
        input.value = rating

        this.paintStars(criterionId, rating)
        this.recalcOverall()
    }

    recalcOverall() {
        const values = this.markInputTargets
            .map((i) => parseFloat(i.value || "0"))
            .filter((v) => v > 0)

        const overall = values.length ? (values.reduce((a, b) => a + b, 0) / values.length) : 0
        const el = document.getElementById("overall_preview")
        if (el) el.textContent = overall.toFixed(1)
    }

    paintStars(criterionId, rating) {
        const stars = this.element.querySelectorAll(`svg[data-criterion-id="${criterionId}"]`)
        stars.forEach((star) => {
            const starRating = parseInt(star.dataset.rating, 10)
            star.setAttribute("fill", starRating <= rating ? "yellow" : "gray")
            star.classList.toggle("text-gray-300", starRating > rating)
        })
    }

    findMarkInput(criterionId) {
        return this.markInputTargets.find((i) => i.dataset.criterionId === criterionId)
    }
}