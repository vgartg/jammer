import { Controller } from "stimulus"

export default class extends Controller {
    static targets = ["tabName"];


    openTab(event) {
        const tabName = event.currentTarget.dataset.tabName;
        let i, tab_content, tab_links;

        tab_content = document.getElementsByClassName("tab_content");
        for (i = 0; i < tab_content.length; i++) {
            tab_content[i].style.display = "none";
        }

        tab_links = document.getElementsByClassName("tab_links");
        for (i = 0; i < tab_links.length; i++) {
            tab_links[i].classList.remove("bg-gray-100");
        }

        document.getElementById(tabName).style.display = "block";
        event.currentTarget.className += " bg-gray-100";
    }
}

