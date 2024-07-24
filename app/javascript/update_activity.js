document.addEventListener("DOMContentLoaded", function() {
    setInterval(function() {
        fetch('/update_activity', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            },
            credentials: 'same-origin'
        });
    }, 30000);
});