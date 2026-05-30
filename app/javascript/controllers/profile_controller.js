import { Controller } from "stimulus"

export default class extends Controller {
    openTab(event) {
        const tabName = event.currentTarget.dataset.tabName;

        document.querySelectorAll(".tab_content").forEach(el => {
            el.classList.add("hidden");
            el.style.display = "";
        });

        document.querySelectorAll(".tab_links").forEach(btn => {
            btn.classList.remove("bg-gray-700", "text-white");
            btn.classList.add("text-gray-400");
        });

        const target = document.getElementById(tabName);
        if (target) target.classList.remove("hidden");

        event.currentTarget.classList.add("bg-gray-700", "text-white");
        event.currentTarget.classList.remove("text-gray-400");
    }
}
