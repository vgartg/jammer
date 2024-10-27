document.addEventListener("DOMContentLoaded", function() {
    setInterval(function() {
        const currentUserMeta = document.getElementById('current-user');
        const isLoggedIn = currentUserMeta.getAttribute('data-current-user') === 'true';

        if (isLoggedIn) {
            fetch('/update_activity', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                },
                credentials: 'same-origin'
            });
        }
    }, 30000);
});
