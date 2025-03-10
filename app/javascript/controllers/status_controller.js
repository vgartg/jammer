import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["status", "reasonField", "customReason"];

    connect() {
        this.toggleReasonField();
    }

    toggleReasonField() {
        if (this.statusTarget.value === '2') {
            this.reasonFieldTarget.style.display = 'block';
        } else {
            this.reasonFieldTarget.style.display = 'none';
            this.customReasonTarget.value = '';
        }
    }

    updateReasonField() {
        if (this.statusTarget.value === '2') {
            this.reasonFieldTarget.style.display = 'block';
        } else {
            this.reasonFieldTarget.style.display = 'none';
            this.customReasonTarget.value = '';
        }
    }
}
