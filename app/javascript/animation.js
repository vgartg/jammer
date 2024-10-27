addEventListener("turbo:submit-start", ({target}) => {
    for (const field of target.elements) {
        field.disabled = true
    }
})

addEventListener("turbo:submit-start", ({target}) => {
    const loading = document.getElementById('blur')
    if (loading) {
        loading.classList.remove('hidden')
    }
})
addEventListener("turbo:submit-start", ({target}) => {
    const loading = document.getElementById('loading')
    if (loading) {
        loading.classList.remove('hidden')
    }
})