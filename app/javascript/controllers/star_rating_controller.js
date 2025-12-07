import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["star", "submitButton", "commentField"];

  connect() {
    this.initialRating = parseInt(document.getElementById("user_mark").value) || 0;
    this.currentRating = this.initialRating;
    this.updateStars(this.currentRating);

    this.initialComment = document.getElementById("rating-comment").value || '';
    this.commentFieldTarget.value = this.initialComment;

    this.submitButtonTarget.style.display = "none";

    // Если рейтинг равен 0, скрыть поле комментария
    this.toggleCommentField();
  }

  updateStars(rating) {
    this.starTargets.forEach((star) => {
      const starRating = parseInt(star.dataset.rating);
      star.style.fill = starRating <= rating ? "#FFD700" : "gray";
    });
  }

  hover(event) {
    const rating = parseInt(event.currentTarget.dataset.rating);
    this.updateStars(rating);
  }

  leave() {
    this.updateStars(this.currentRating);
  }

  setRating(event) {
    this.currentRating = parseInt(event.currentTarget.dataset.rating);
    this.updateStars(this.currentRating);

    document.getElementById("user_mark").value = this.currentRating;

    // Обновляем видимость поля комментария в зависимости от рейтинга
    this.toggleCommentField();

    this.toggleSubmitButton();
  }

  handleCommentInput() {
    this.toggleSubmitButton();
    const hiddenField = document.getElementById("rating-comment");
    hiddenField.value = this.commentFieldTarget.value.trim();
  }

  toggleSubmitButton() {
    const comment = this.commentFieldTarget.value.trim();
    if (this.currentRating !== this.initialRating || comment !== '') {
      this.submitButtonTarget.style.display = "inline-block";
    } else {
      this.submitButtonTarget.style.display = "none";
    }
  }

  // Логика скрытия или отображения поля комментария в зависимости от рейтинга
  toggleCommentField() {
    if (this.currentRating > 0) {
      this.commentFieldTarget.style.display = "block";
    } else {
      this.commentFieldTarget.style.display = "none";
    }
  }

  submitRating(event) {
    const form = document.getElementById("rating-form");
    document.getElementById("rating-comment").value = this.commentFieldTarget.value;
    form.submit();
  }
}
