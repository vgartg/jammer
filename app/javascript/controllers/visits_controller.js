import { Controller } from "stimulus";
import Chart from "chart.js/auto";

export default class extends Controller {
    static targets = ["chart"];
    static values = {
        registeredUsersLabel: String,
        userCountLabel: String,
        dateLabel: String
    };

    connect() {
        this.fetchData(30);
    }

    fetchData(days) {
        fetch(`/admin/registrations_data?days=${days}`)
            .then(response => response.json())
            .then(data => this.renderChart(data))
            .catch(error => console.error("Error fetching data:", error));
    }

    renderChart(registrationsData) {
        const dates = Object.keys(registrationsData);
        const counts = dates.map(d => registrationsData[d] || 0);

        if (this.chart) {
            this.chart.destroy();
        }

        this.chart = new Chart(this.chartTarget, {
            type: "line",
            data: {
                labels: dates,
                datasets: [
                    {
                        label: this.registeredUsersLabelValue,
                        data: counts,
                        borderColor: "rgba(99, 102, 241, 1)",
                        backgroundColor: "rgba(99, 102, 241, 0.15)",
                        fill: true,
                        tension: 0.4,
                    }
                ]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { labels: { color: "#d1d5db" } }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: "rgba(255,255,255,0.05)" },
                        ticks: {
                            color: "#9ca3af",
                            callback: value => Number.isInteger(value) ? value : ''
                        },
                        title: { display: true, text: this.userCountLabelValue, color: "#9ca3af" }
                    },
                    x: {
                        grid: { color: "rgba(255,255,255,0.05)" },
                        ticks: { color: "#9ca3af" },
                        title: { display: true, text: this.dateLabelValue, color: "#9ca3af" }
                    }
                }
            }
        });
    }

    changeTimeFrame(event) {
        this.fetchData(event.target.value);
    }
}
