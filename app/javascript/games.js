document.addEventListener("DOMContentLoaded", function() {
    const searchInput = document.getElementById('game-search-input');
    const resultsContainer = document.getElementById('autocomplete-results');

    searchInput.addEventListener('input', function() {
        const query = this.value.trim();

        if (query.length === 0) {
            resultsContainer.innerHTML = '';
            return;
        }

        fetch(`/games_showcase.json?search=${encodeURIComponent(query)}`)
            .then(response => response.json())
            .then(data => {
                resultsContainer.innerHTML = '';
                if (data.length > 0) {
                    const ul = document.createElement('ul');
                    ul.classList.add('autocomplete-result-set');

                    data.forEach(game => {
                        const li = document.createElement('li');
                        li.classList.add('autocomplete-result', 'game_result');

                        const a = document.createElement('a');
                        a.setAttribute('href', `/games/${game.id}`);
                        a.textContent = game.name;

                        li.appendChild(a);
                        ul.appendChild(li);
                    });

                    resultsContainer.appendChild(ul);
                } else {
                    resultsContainer.innerHTML = '<p>Ничего не найдено</p>';
                }
            })
            .catch(error => {
                console.error('Error fetching search results:', error);
                resultsContainer.innerHTML = '<p>Failed to fetch results</p>';
            });
    });
});
