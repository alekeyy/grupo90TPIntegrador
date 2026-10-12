/* ==========================================================================
   Sistema de Gestión - Bomberos Voluntarios
   Comportamiento del menú lateral y utilidades de interfaz.
   ========================================================================== */
(function () {
    'use strict';

    /** Marca como activo el enlace del menú que corresponde a la página actual
     *  y despliega el grupo que lo contiene. */
    function marcarMenuActivo() {
        var actual = (window.location.pathname + window.location.search).toLowerCase();
        var ruta = window.location.pathname.toLowerCase();
        var enlaces = document.querySelectorAll('.app-nav a.nav-link');
        var elegido = null;

        // 1) coincidencia exacta (incluye querystring, p. ej. Catalogo.aspx?tipo=Rangos)
        enlaces.forEach(function (a) {
            var href = (a.pathname + a.search).toLowerCase();
            if (!elegido && href === actual) elegido = a;
        });
        // 2) coincidencia por ruta (p. ej. MisionDetalle.aspx -> no existe en el menú)
        if (!elegido) {
            enlaces.forEach(function (a) {
                if (!elegido && a.pathname.toLowerCase() === ruta && !a.search) elegido = a;
            });
        }
        // 3) páginas de detalle: se asocian al listado del mismo módulo
        if (!elegido && ruta.indexOf('misiondetalle.aspx') >= 0) {
            enlaces.forEach(function (a) {
                if (!elegido && a.pathname.toLowerCase().indexOf('misiones.aspx') >= 0) elegido = a;
            });
        }
        if (!elegido && (ruta === '/' || ruta.endsWith('/default.aspx'))) elegido = enlaces[0];

        if (elegido) {
            elegido.classList.add('active');
            var grupo = elegido.closest('.collapse');
            if (grupo) {
                grupo.classList.add('show');
                var boton = document.querySelector('[data-bs-target="#' + grupo.id + '"]');
                if (boton) boton.setAttribute('aria-expanded', 'true');
            }
        }
    }

    /** Desplaza la vista hasta el formulario de edición cuando se abre. */
    function enfocarFormulario() {
        var form = document.querySelector('.card-form');
        if (form) {
            form.scrollIntoView({ behavior: 'smooth', block: 'start' });
            var primero = form.querySelector('input:not([type=hidden]):not([disabled]), select, textarea');
            if (primero) primero.focus({ preventScroll: true });
        }
    }

    /** Oculta automáticamente las alertas de éxito después de unos segundos. */
    function autocerrarAlertas() {
        document.querySelectorAll('.alert-success').forEach(function (al) {
            setTimeout(function () {
                if (window.bootstrap && bootstrap.Alert) bootstrap.Alert.getOrCreateInstance(al).close();
            }, 6000);
        });
    }

    document.addEventListener('DOMContentLoaded', function () {
        marcarMenuActivo();
        enfocarFormulario();
        autocerrarAlertas();
    });
})();
