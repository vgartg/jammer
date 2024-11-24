$(document).on('turbolinks:load', function() {
    $('.delete-user-link').on('click', function(e) {
        e.preventDefault();
        let userId = $(this).data('user_id');
        let jamId = $(this).data('jam_id');
        $.ajax({
            url: `/jams/${jamId}/jury_members/${userId}`,
            type: 'DELETE',
            dataType: 'json',
            success: function(data) {
                location.reload(); // Перезагрузить страницу после удаления
            },
            error: function(error) {
                console.error("Ошибка при удалении пользователя:", error);
                alert("Ошибка при удалении пользователя. Попробуйте еще раз.");
            }
        });
    });
});