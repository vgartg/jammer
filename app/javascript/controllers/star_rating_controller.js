import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["star"];
// Метод вызывается при подключении контроллера
  connect() {
    this.currentRating = 0;
    this.updateStars(0);
  }

  // Обновление рейгинга
  updateStars(rating) {
    this.starTargets.forEach((star) => {
      const starRating = parseInt(star.dataset.rating);
      if (starRating <= rating) {
        star.style.fill = "#FFD700"; // Золотой цвет
      } else {
        star.style.fill = "gray";
      }
    });
  }

  // Обработка наведения мыши для предварительного просмотра рейтинга
  hover(event) {
    const rating = parseInt(event.currentTarget.dataset.rating);
    this.updateStars(rating);
  }

  // Сброс звезд на текущий рейтинг при уводе курсора
  leave() {
    this.updateStars(this.currentRating);
  }

  // Установка нового рейтинга при клике на звезду
  setRating(event) {
    this.currentRating = parseInt(event.currentTarget.dataset.rating);
    this.updateStars(this.currentRating);
  }
}
