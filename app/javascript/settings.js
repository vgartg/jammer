document.addEventListener('DOMContentLoaded', function () {
    let phoneInput = document.getElementById('phone_number');

    phoneInput.addEventListener('input', function (e) {
        let x = e.target.value.replace(/\D/g, '');
        let formattedValue = '+7 (';

        if (x.length > 1) {
            formattedValue += x.substring(1, 4);
        }
        if (x.length > 4) {
            formattedValue += ') ' + x.substring(4, 7);
        }
        if (x.length > 7) {
            formattedValue += '-' + x.substring(7, 9);
        }
        if (x.length > 9) {
            formattedValue += '-' + x.substring(9, 11);
        }

        e.target.value = formattedValue;
    });

    const closeButton = document.querySelector('#notification-area button');
    if (closeButton) {
        closeButton.addEventListener('click', function() {
            document.querySelector('#notification-area').innerHTML = '';
        });
    }
});