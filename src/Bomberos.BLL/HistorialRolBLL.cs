using System;
using System.Collections.Generic;
using System.Linq;
using Bomberos.DAL;
using Bomberos.Entities;

namespace Bomberos.BLL
{
    /// <summary>
    /// Reglas de negocio del historial de roles.
    /// Un voluntario puede tener varios roles a la vez, pero no el mismo rol vigente dos veces.
    /// </summary>
    public class HistorialRolBLL
    {
        private readonly HistorialRolDAL _dal = new HistorialRolDAL();

        public List<HistorialRol> Listar(int? idVoluntario, bool soloVigentes)
        {
            return _dal.Listar(idVoluntario, soloVigentes);
        }

        public HistorialRol Obtener(int id)
        {
            return _dal.Obtener(id);
        }

        public int Guardar(HistorialRol h)
        {
            Validador v = new Validador()
                .Seleccionado(h.IDVoluntario, "un voluntario")
                .Seleccionado(h.IDRol, "un rol")
                .FechaValida(h.FechaDesde, "Desde")
                .Regla(!h.FechaHasta.HasValue || h.FechaHasta.Value >= h.FechaDesde,
                       "La fecha hasta no puede ser anterior a la fecha desde.");

            if (h.IDVoluntario > 0 && h.IDRol > 0)
            {
                DateTime hasta = h.FechaHasta ?? DateTime.MaxValue;
                bool superpuesto = _dal.Listar(h.IDVoluntario, false)
                    .Any(x => x.IDRol == h.IDRol && x.IDHistorialRol != h.IDHistorialRol
                              && x.FechaDesde < hasta && (x.FechaHasta ?? DateTime.MaxValue) > h.FechaDesde);
                v.Regla(!superpuesto, "El voluntario ya tiene asignado ese rol en un período que se superpone.");
            }
            v.Lanzar();

            if (h.IDHistorialRol == 0)
                return _dal.Insertar(h);

            _dal.Actualizar(h);
            return h.IDHistorialRol;
        }

        /// <summary>Finaliza la vigencia de un rol en la fecha indicada.</summary>
        public void FinalizarVigencia(int id, DateTime fechaHasta)
        {
            HistorialRol h = _dal.Obtener(id);
            new Validador()
                .Regla(h != null, "El registro no existe.")
                .FechaValida(fechaHasta, "Fecha de finalización")
                .Lanzar();

            new Validador()
                .Regla(h.Vigente, "La vigencia de este rol ya fue finalizada.")
                .Regla(fechaHasta >= h.FechaDesde, "La fecha de finalización no puede ser anterior a la fecha desde.")
                .Lanzar();

            _dal.Finalizar(id, fechaHasta);
        }

        public void Eliminar(int id)
        {
            _dal.Eliminar(id);
        }
    }
}
