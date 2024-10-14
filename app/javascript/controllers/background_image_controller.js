import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["input", "previewImg", "currentBackgroundImg"];

    initialize() {
        this.updatePreview = this.updatePreview.bind(this);
    }

    connect() {
        this.inputTarget.addEventListener("change", this.updatePreview);
    }

    disconnect() {
        this.inputTarget.removeEventListener("change", this.updatePreview);
    }

    updatePreview(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = (e) => {
                // Скрыть текущее изображение
                if (this.hasCurrentBackgroundImgTarget) {
                    this.currentBackgroundImgTarget.style.display = "none";
                }

                // Показать превью нового изображения
                if (this.hasPreviewImgTarget) {
                    this.previewImgTarget.src = e.target.result;
                    this.previewImgTarget.classList.remove("hidden");
                }
            };
            reader.onerror = () => {
                // Обработка ошибок чтения файла
                console.error("Ошибка чтения файла.");
            };
            reader.readAsDataURL(file);
        } else {
            // Показать текущее изображение, если файл не выбран
            if (this.hasCurrentBackgroundImgTarget) {
                this.currentBackgroundImgTarget.style.display = "block";
            }
            if (this.hasPreviewImgTarget) {
                this.previewImgTarget.classList.add("hidden");
            }
        }
    }
}
