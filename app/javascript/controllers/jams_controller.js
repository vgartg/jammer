import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["allJams", "myJams", "showAll", "showMine", "searchForm"]

    connect() {
        this.timeout = null;
        this.displayAllJams();
    }

    displayAllJams() {
        this.allJamsTarget.classList.remove("hidden");
        this.searchFormTarget.classList.remove("hidden");
        this.myJamsTarget.classList.add("hidden");

        this.showAllTarget.classList.add("font-bold", "text-gray-800");
        this.showMineTarget.classList.remove("font-bold", "text-gray-800");
    }

    displayMyJams() {
        this.myJamsTarget.classList.remove("hidden");
        this.allJamsTarget.classList.add("hidden");
        this.searchFormTarget.classList.add("hidden");

        this.showMineTarget.classList.add("font-bold", "text-gray-800");
        this.showAllTarget.classList.remove("font-bold", "text-gray-800");
    }

    toggleJams(event) {
        if (event.currentTarget.dataset.jamsTarget === "showAll") {
            this.displayAllJams();
        } else if (event.currentTarget.dataset.jamsTarget === "showMine") {
            this.displayMyJams();
        }
    }
}