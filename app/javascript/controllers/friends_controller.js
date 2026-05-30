import { Controller } from "stimulus"

export default class extends Controller {
    static values = { defaultTab: String };

    connect() {
        this._activateTab(this.defaultTabValue || 'friends');
    }

    openTab(event) {
        this._activateTab(event.currentTarget.dataset.tabName);
    }

    _activateTab(tabName) {
        document.querySelectorAll(".tab_content").forEach(el => el.classList.add("hidden"));
        document.querySelectorAll(".tab_links").forEach(btn => {
            btn.classList.remove("bg-gray-700", "text-white");
            btn.classList.add("text-gray-400");
        });

        const target = document.getElementById(tabName);
        if (target) target.classList.remove("hidden");

        const activeBtn = document.querySelector(`[data-tab-name="${tabName}"]`);
        if (activeBtn) {
            activeBtn.classList.add("bg-gray-700", "text-white");
            activeBtn.classList.remove("text-gray-400");
        }
    }
}
