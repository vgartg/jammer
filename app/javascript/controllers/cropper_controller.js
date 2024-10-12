import { Controller } from "stimulus";
import Cropper from "cropperjs";
import 'cropperjs/dist/cropper.css';

export default class extends Controller {
    static targets = ['input', 'image', 'modal', 'cropButton', 'cancelButton'];

    connect() {
        this.cropper = null;
        this.inputTarget.addEventListener('change', this.loadImage.bind(this));
        this.cropButtonTarget.addEventListener('click', this.crop.bind(this));
        this.cancelButtonTarget.addEventListener('click', this.close.bind(this));
    }

    loadImage(event) {
        const files = event.target.files;
        if (files && files.length > 0) {
            const file = files[0];
            const reader = new FileReader();
            reader.onload = (e) => {
                this.imageTarget.src = e.target.result;
                this.modalTarget.classList.remove('hidden');

                if (this.cropper) {
                    this.cropper.destroy();
                }

                this.cropper = new Cropper(this.imageTarget, {
                    aspectRatio: 1,
                    viewMode: 1,
                    preview: '.preview'
                });
            };
            reader.readAsDataURL(file);
        }
    }

    crop() {
        if (this.cropper) {
            const canvas = this.cropper.getCroppedCanvas({
                width: 150,
                height: 150
            });

            canvas.toBlob((blob) => {
                const url = URL.createObjectURL(blob);
                const img = document.querySelector('.avatar-image');
                img.src = url;

                const dataTransfer = new DataTransfer();
                dataTransfer.items.add(new File([blob], 'avatar.jpg', { type: 'image/jpeg' }));
                this.inputTarget.files = dataTransfer.files;

                this.close();
            }, 'image/jpeg');
        }
    }

    close() {
        this.modalTarget.classList.add('hidden');
        if (this.cropper) {
            this.cropper.destroy();
            this.cropper = null;
        }
    }
}
