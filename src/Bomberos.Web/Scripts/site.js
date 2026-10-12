// Marca como activo el enlace del menú de la página actual y despliega su grupo.
document.addEventListener('DOMContentLoaded', function () {
    var ruta = window.location.pathname.toLowerCase();
    document.querySelectorAll('.app-nav a.nav-link').forEach(function (a) {
        if (a.pathname.toLowerCase() === ruta) {
            a.classList.add('active');
            var grupo = a.closest('.collapse');
            if (grupo) {
                grupo.classList.add('show');
                var boton = document.querySelector('[data-bs-target="#' + grupo.id + '"]');
                if (boton) boton.setAttribute('aria-expanded', 'true');
            }
        }
    });
});
