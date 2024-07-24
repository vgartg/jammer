document.addEventListener('DOMContentLoaded', function() {
    const openButton = document.getElementById('open-header-button');
    const closeButton = document.getElementById('close-header-button');
    const mobileMenu = document.getElementById('mobile-header-block');

    openButton.addEventListener('click', function() {
        mobileMenu.classList.remove('hidden');
    });

    closeButton.addEventListener('click', function() {
        mobileMenu.classList.add('hidden');
    });
});