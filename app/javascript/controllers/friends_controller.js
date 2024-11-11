import { Controller } from "stimulus"

export default class extends Controller {
    static targets = ["tab-name"];
    openTab(event) {
        const tabName = event.currentTarget.dataset.tabName;
        let i, tab_content, tab_links;

        tab_content = document.getElementsByClassName("tab_content");
        for (i = 0; i < tab_content.length; i++) {
            tab_content[i].style.display = "none";
        }

        tab_links = document.getElementsByClassName("tab_links");
        for (i = 0; i < tab_links.length; i++) {
            tab_links[i].className = tab_links[i].className.replace(" active", "");
        }

        document.getElementById(tabName).style.display = "block";
        event.currentTarget.className += " active";

        if (tabName === 'sent_requests') {
            document.getElementById("btnSentRequests").classList.add("bg-blue-700");
            document.getElementById("btnReceivedRequests").classList.remove("bg-blue-700");
        } else if (tabName === 'received_requests') {
            document.getElementById("btnSentRequests").classList.remove("bg-blue-700");
            document.getElementById("btnReceivedRequests").classList.add("bg-blue-700");
        }
    }
}