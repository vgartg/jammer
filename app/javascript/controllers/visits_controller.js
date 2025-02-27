import { Controller } from "stimulus";
import Chart from "chart.js/auto";

export default class extends Controller {
    static targets = ["chart"];

    connect() {
        this.fetchData(30);
    }

    fetchData(days) {
        const visitsPromise = fetch(`/admin/visits_data?days=${days}`).then(response => response.json());
        const registrationsPromise = fetch(`/admin/registrations_data?days=${days}`).then(response => response.json());

        Promise.all([visitsPromise, registrationsPromise])
            .then(([visitsData, registrationsData]) => {
                this.renderChart(visitsData, registrationsData);
            })
            .catch(error => console.error("Error fetching data:", error));
    }

    renderChart(visitsData, registrationsData) {
        const dates = Object.keys(visitsData);
        const visits = Object.values(visitsData);
        const registrations = Object.values(registrationsData);

        const maxLength = Math.max(visits.length, registrations.length);
        const registrationCounts = new Array(maxLength).fill(0);

        dates.forEach((date, index) => {
            registrationCounts[index] = registrationsData[date] || 0;
        });

        if (this.chart) {
            this.chart.destroy();
        }

        this.chart = new Chart(this.chartTarget, {
            type: "line",
            data: {
                labels: dates,
                datasets: [
                    {
                        label: "Активные пользователи",
                        data: visits,
                        borderColor: "rgba(75, 192, 192, 1)",
                        backgroundColor: "rgba(75, 192, 192, 0.2)",
                        fill: true,
                    },
                    {
                        label: "Зарегистрированные пользователи",
                        data: registrationCounts,
                        borderColor: "rgba(153, 102, 255, 1)",
                        backgroundColor: "rgba(153, 102, 255, 0.2)",
                        fill: true,
                    }
                ]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Количество пользователей'
                        },
                        ticks: {
                            callback: function(value) {
                                return Number.isInteger(value) ? value : '';
                            }
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: 'Дата'
                        }
                    }
                }
            }
        });
    }

    changeTimeFrame(event) {
        const selectedDays = event.target.value;
        this.fetchData(selectedDays);
    }
}
