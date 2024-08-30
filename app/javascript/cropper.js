import Cropper from 'cropperjs';
import 'cropperjs/dist/cropper.css';

document.addEventListener('DOMContentLoaded', () => {
    const avatarInput = document.querySelector('input[type="file"][name="user[avatar]"]');
    const cropperModal = document.getElementById('cropperModal');
    const image = document.getElementById('image');
    const cropButton = document.getElementById('cropButton');
    const cancelButton = document.getElementById('cancelButton');
    let cropper;

    avatarInput.addEventListener('change', (event) => {
        const files = event.target.files;
        if (files && files.length > 0) {
            const file = files[0];
            const reader = new FileReader();
            reader.onload = (e) => {
                image.src = e.target.result;
                cropperModal.classList.remove('hidden');

                if (cropper) {
                    cropper.destroy();
                }

                cropper = new Cropper(image, {
                    aspectRatio: 1,
                    viewMode: 1,
                    preview: '.preview'
                });
            };
            reader.readAsDataURL(file);
        }
    });

    cropButton.addEventListener('click', () => {
        if (cropper) {
            const canvas = cropper.getCroppedCanvas({
                width: 150,
                height: 150
            });

            canvas.toBlob((blob) => {
                const url = URL.createObjectURL(blob);
                const img = document.querySelector('.avatar-image');
                img.src = url;

                const dataTransfer = new DataTransfer();
                dataTransfer.items.add(new File([blob], 'avatar.jpg', { type: 'image/jpeg' }));
                avatarInput.files = dataTransfer.files;

                cropperModal.classList.add('hidden');
                cropper.destroy();
                cropper = null;
            }, 'image/jpeg');
        }
    });

    cancelButton.addEventListener('click', () => {
        cropperModal.classList.add('hidden');
        if (cropper) {
            cropper.destroy();
            cropper = null;
        }
    });
});
