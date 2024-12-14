import {Controller} from "stimulus";

export default class extends Controller {
    static targets = ["lastActiveAt"];

    connect() {
        if (this.hasLastActiveAtTarget) {
            this.updateStatus();
        }
    }

    updateStatus() {

        let lastActiveAtString = this.lastActiveAtTarget.dataset.lastActiveAt;
        let lastActiveAtUTC = new Date(lastActiveAtString);

        let userTimezoneOffset = new Date().getTimezoneOffset() * 60000; // в миллисекундах
        let lastActiveAtLocal = new Date(lastActiveAtUTC.getTime() - userTimezoneOffset);

        let statusElement = this.lastActiveAtTarget;
        let now = new Date();
        let timeDiff = now - lastActiveAtLocal;

        let secondsDiff = Math.floor(timeDiff / 1000);
        let minutesDiff = Math.floor(secondsDiff / 60);
        let hoursDiff = Math.floor(minutesDiff / 60);
        let daysDiff = Math.floor(hoursDiff / 24);

        const translations = {
            en: {
                onlineSinceDays: (daysDiff) => `Last seen ${daysDiff} ${this.dayTitle(daysDiff, ['days', 'day'])} ago`,
                onlineSinceHours: (hoursDiff) => `Last seen ${hoursDiff} ${this.dayTitle(hoursDiff, ['hours', 'hour'])} ago`,
                onlineSinceMinutes: (minutesDiff) => `Last seen ${minutesDiff} ${this.dayTitle(minutesDiff, ['minutes', 'minute'])} ago`,
                online: 'Online',
            },
            ru: {
                onlineSinceDays: (daysDiff) => `Был в сети ${daysDiff} ${this.dayTitle(daysDiff, ['дней', 'день', 'дня'])} назад`,
                onlineSinceHours: (hoursDiff) => `Был в сети ${hoursDiff} ${this.dayTitle(hoursDiff, ['часов', 'час', 'часа'])} назад`,
                onlineSinceMinutes: (minutesDiff) => `Был в сети ${minutesDiff} ${this.dayTitle(minutesDiff, ['минут', 'минуту', 'минуты'])} назад`,
                online: 'В сети',
            }
        };
        const locale = this.getLocale();


        if (daysDiff > 0) {
            statusElement.textContent = translations[locale].onlineSinceDays(daysDiff);
        } else if (hoursDiff > 0) {
            statusElement.textContent = translations[locale].onlineSinceHours(hoursDiff);
        } else if (minutesDiff > 0) {
            statusElement.textContent = translations[locale].onlineSinceMinutes(minutesDiff);
        } else {
            statusElement.textContent = translations[locale].online;
        }

        if (statusElement.textContent === translations[locale].online) {
            statusElement.classList.remove('text-gray-600');
            statusElement.classList.add('text-green-500');
        } else {
            statusElement.classList.remove('text-green-500');
            statusElement.classList.add('text-gray-600');
        }
    }

    dayTitle(number, titles) {
        if (number > 10 && [11, 12, 13, 14].includes(number % 100)) return titles[0];
        let lastNum = number % 10;
        if (lastNum === 1) return titles[1];
        if ([2, 3, 4].includes(lastNum)) return titles[2];
        return titles[0];
    }

    getLocale() {
        const locale = window.location.pathname
        if (locale.includes('ru')) {
            return "ru";
        } else {
            return "en"
        }
    }
}