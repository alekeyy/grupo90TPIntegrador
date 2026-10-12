using System;
using System.Collections.Generic;
using System.Linq;
using Bomberos.DAL;
using Bomberos.Entities;

namespace Bomberos.BLL
{
    /// <summary>
    /// Reglas de negocio del historial de rangos.
    /// Regla principal: un voluntario no puede tener más de un rango vigente al mismo tiempo.
    /// (La regla se valida aquí, en el Stored Procedure y con un índice único filtrado).
    /// </summary>
    public class HistorialRangoBLL
    {
        private readonly HistorialRangoDAL _dal = new HistorialRangoDAL();

        public List<HistorialRango> Listar(int? idVoluntario, bool soloVigentes)
        {
            return _dal.Listar(idVoluntario, soloVigentes);
        }

        public HistorialRango Obtener(int id)
        {
            return _dal.Obtener(id);
        }

        /// <summary>Rango vigente del voluntario o null si no tiene.</summary>
        public HistorialRango ObtenerVigente(int idVoluntario)
        {
            return _dal.Listar(idVoluntario, true).FirstOrDefault();
        }

        public int Guardar(HistorialRango h)
        {
            Validador v = new Validador()
                .Seleccionado(h.IDVoluntario, "un voluntario")
                .Seleccionado(h.IDRango, "un rango")
                .FechaValida(h.FechaDesde, "Desde")
                .Regla(!h.FechaHasta.HasValue || h.FechaHasta.Value >= h.FechaDesde,
                       "La fecha hasta no puede ser anterior a la fecha desde.");

            if (h.IDVoluntario > 0)
            {
                List<HistorialRango> historial = _dal.Listar(h.IDVoluntario, false)
                    .Where(x => x.IDHistorialRango != h.IDHistorialRango).ToList();

                v.Regla(h.FechaHasta.HasValue || !historial.Any(x => x.Vigente),
                        "El voluntario ya posee un rango vigente. Finalice el rango actual o utilice \"Registrar ascenso\".");

                DateTime hasta = h.FechaHasta ?? DateTime.MaxValue;
                v.Regla(!historial.Any(x => x.FechaDesde < hasta && (x.FechaHasta ?? DateTime.MaxValue) > h.FechaDesde),
                        "El período se superpone con otro rango del voluntario. Un voluntario no puede tener dos rangos al mismo tiempo.");
            }
            v.Lanzar();

            if (h.IDHistorialRango == 0)
                return _dal.Insertar(h);

            _dal.Actualizar(h);
            return h.IDHistorialRango;
        }

        /// <summary>
        /// Registra un ascenso: finaliza el rango vigente en la fecha indicada y crea el nuevo rango vigente.
        /// </summary>
        public int RegistrarAscenso(int idVoluntario, int idRango, DateTime fecha)
        {
            HistorialRango actual = idVoluntario > 0 ? ObtenerVigente(idVoluntario) : null;

            new Validador()
                .Seleccionado(idVoluntario, "un voluntario")
                .Seleccionado(idRango, "el nuevo rango")
                .FechaValida(fecha, "Fecha del ascenso")
                .Regla(fecha.Date <= DateTime.Today, "La fecha del ascenso no puede ser futura.")
                .Regla(actual == null || actual.IDRango != idRango, "El voluntario ya posee ese rango como rango vigente.")
                .Regla(actual == null || fecha >= actual.FechaDesde, "La fecha del ascenso no puede ser anterior al inicio del rango vigente.")
                .Lanzar();

            return _dal.Ascender(idVoluntario, idRango, fecha);
        }

        public void Eliminar(int id)
        {
            _dal.Eliminar(id);
        }
    }
}
