document.addEventListener('DOMContentLoaded', function() {
    const nButton = document.getElementById('dashboard_user_menu_button');
    const profileMenu = document.getElementById('dashboard_profile_menu');

    const grayBlock = document.getElementById('dashboard_gray_opacity_block');
    const leftBlock = document.getElementById('dashboard_left_mobile_block');
    const openMobileButton = document.getElementById('dashboard_open_mobile_menu');
    const closeMobileButton = document.getElementById('dashboard_close_mobile_menu');

    nButton.addEventListener('click', function() {
        if (profileMenu.classList.contains('hidden')) {
            profileMenu.classList.remove('hidden');
        }
        else {
            profileMenu.classList.add('hidden');
        }
    });

    openMobileButton.addEventListener('click', function () {
        grayBlock.classList.remove('opacity-0');
        leftBlock.classList.remove('-translate-x-full');
        grayBlock.classList.remove('hidden');
        grayBlock.classList.add('opacity-100');
        leftBlock.classList.add('translate-x-0');
    })

    closeMobileButton.addEventListener('click', function () {
        grayBlock.classList.remove('opacity-100');
        leftBlock.classList.remove('translate-x-0');
        grayBlock.classList.add('opacity-0');
        leftBlock.classList.add('-translate-x-full');
        grayBlock.classList.add('hidden');
    })

});