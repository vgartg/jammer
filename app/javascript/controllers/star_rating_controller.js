// star_rating_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["star"];

    connect() {
        this.currentRating = 0; // Initialize the current rating
    }

    // Handle mouse hover to preview rating
    hover(event) {
        const rating = parseInt(event.currentTarget.dataset.rating);
        this.updateStars(rating);
    }

    // Reset to current rating when mouse leaves
    leave() {
        this.updateStars(this.currentRating);
    }

    // Set rating on click
    setRating(event) {
        this.currentRating = parseInt(event.currentTarget.dataset.rating);
        console.log(`Selected rating: ${this.currentRating}`);
        this.updateStars(this.currentRating);
    }

    // Update the star colors based on rating
    updateStars(rating) {
        this.starTargets.forEach((star) => {
            const starRating = parseInt(star.dataset.rating);
            star.style.fill = starRating <= rating ? "#FFD700" : "gray"; // Gold for selected, gray otherwise
        });
    }
}
