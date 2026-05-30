import { Controller } from "stimulus"
import Cropper from "cropperjs"
import 'cropperjs/dist/cropper.css'

export default class extends Controller {
  static targets = ["fileInput", "modal", "image", "cropButton", "cancelButton", "preview"]

  connect() {
    this.cropper = null
    this.fileInputTarget.addEventListener('change', this.loadImage.bind(this))
    this.cropButtonTarget.addEventListener('click', this.crop.bind(this))
    this.cancelButtonTarget.addEventListener('click', this.cancel.bind(this))
  }

  loadImage(event) {
    const file = event.target.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (e) => {
      this.imageTarget.src = e.target.result
      this.modalTarget.classList.remove("hidden")

      if (this.cropper) {
        this.cropper.destroy()
      }

      this.cropper = new Cropper(this.imageTarget, {
        aspectRatio: 4,
        viewMode: 1,
        dragMode: 'move',
        autoCropArea: 1,
        restore: false,
        guides: false,
        center: false,
        highlight: false,
        cropBoxMovable: false,
        cropBoxResizable: false,
        toggleDragModeOnDblclick: false,
      })
    }
    reader.readAsDataURL(file)
  }

  crop() {
    if (!this.cropper) return

    const canvas = this.cropper.getCroppedCanvas({ width: 1200, height: 300 })

    canvas.toBlob((blob) => {
      if (this.hasPreviewTarget) {
        this.previewTarget.src = URL.createObjectURL(blob)
        this.previewTarget.classList.remove("hidden")
        const wrap = document.getElementById('bg-crop-preview-wrap')
        if (wrap) wrap.classList.remove("hidden")
      }

      const dt = new DataTransfer()
      dt.items.add(new File([blob], 'background.jpg', { type: 'image/jpeg' }))
      this.fileInputTarget.files = dt.files

      this.close(false)
    }, 'image/jpeg', 0.92)
  }

  cancel() {
    this.close(true)
  }

  close(clearInput = true) {
    this.modalTarget.classList.add("hidden")
    if (clearInput) {
      this.fileInputTarget.value = ""
      if (this.hasPreviewTarget) this.previewTarget.classList.add("hidden")
    }
    if (this.cropper) {
      this.cropper.destroy()
      this.cropper = null
    }
  }
}
