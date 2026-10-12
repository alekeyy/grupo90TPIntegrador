using System;
using System.Collections.Generic;
using Bomberos.DAL;
using Bomberos.Entities;

namespace Bomberos.BLL
{
    /// <summary>
    /// Reglas de negocio de Guardias.
    /// </summary>
    public class GuardiaBLL
    {
        private readonly GuardiaDAL _dal = new GuardiaDAL();

        public List<Guardia> Listar(int? idVoluntario, DateTime? desde, DateTime? hasta)
        {
            if (desde.HasValue && hasta.HasValue && desde > hasta)
                throw new ValidacionException("La fecha 'desde' no puede ser posterior a la fecha 'hasta'.");
            return _dal.Listar(idVoluntario, desde, hasta);
        }

        public Guardia Obtener(int id)
        {
            return _dal.Obtener(id);
        }

        public int Guardar(Guardia g)
        {
            new Validador()
                .Seleccionado(g.IDVoluntario, "un voluntario")
                .FechaValida(g.Fecha, "Fecha")
                .Regla(g.HoraInicio != g.HoraFin, "La hora de inicio y la hora de fin no pueden ser iguales.")
                .Regla(g.HoraInicio >= TimeSpan.Zero && g.HoraInicio < TimeSpan.FromDays(1)
                       && g.HoraFin >= TimeSpan.Zero && g.HoraFin < TimeSpan.FromDays(1), "Las horas deben estar entre 00:00 y 23:59.")
                .Lanzar();

            // La superposición de guardias del mismo voluntario se valida en sp_Guardias_Validar.
            if (g.IDGuardia == 0)
                return _dal.Insertar(g);

            _dal.Actualizar(g);
            return g.IDGuardia;
        }

        public void Eliminar(int id)
        {
            _dal.Eliminar(id);
        }
    }
}
