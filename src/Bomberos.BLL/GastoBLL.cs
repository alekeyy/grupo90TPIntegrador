using System;
using System.Collections.Generic;
using Bomberos.DAL;
using Bomberos.Entities;

namespace Bomberos.BLL
{
    /// <summary>
    /// Reglas de negocio de Gastos.
    /// Regla: debe seleccionarse un voluntario autorizador existente (y no dado de baja).
    /// </summary>
    public class GastoBLL
    {
        private readonly GastoDAL _dal = new GastoDAL();
        private readonly VoluntarioDAL _voluntarioDal = new VoluntarioDAL();

        public List<Gasto> Listar(DateTime? desde, DateTime? hasta, int? idTipoGasto, int? idVoluntario)
        {
            if (desde.HasValue && hasta.HasValue && desde > hasta)
                throw new ValidacionException("La fecha 'desde' no puede ser posterior a la fecha 'hasta'.");
            return _dal.Listar(desde, hasta, idTipoGasto, idVoluntario);
        }

        public Gasto Obtener(int id)
        {
            return _dal.Obtener(id);
        }

        public int Guardar(Gasto g)
        {
            g.Descripcion = Texto.Normalizar(g.Descripcion);

            Validador v = new Validador()
                .Seleccionado(g.IDTipoGasto, "un tipo de gasto")
                .Seleccionado(g.IDVoluntarioAutorizador, "un voluntario autorizador")
                .FechaValida(g.Fecha, "Fecha")
                .Regla(g.Fecha.Date <= DateTime.Today, "La fecha del gasto no puede ser futura.")
                .Regla(g.Monto > 0, "El monto debe ser mayor a cero.")
                .Regla(g.Monto <= AporteBLL.MontoMaximo, "El monto supera el máximo permitido.")
                .LongitudMaxima(g.Descripcion, 250, "Descripción");

            if (g.IDVoluntarioAutorizador > 0)
            {
                Voluntario autorizador = _voluntarioDal.Obtener(g.IDVoluntarioAutorizador);
                v.Regla(autorizador != null, "El voluntario autorizador seleccionado no existe.");
                // En una modificación se admite conservar el autorizador original aunque luego haya sido dado de baja.
                Gasto original = g.IDGasto > 0 ? _dal.Obtener(g.IDGasto) : null;
                bool conservaAutorizador = original != null && original.IDVoluntarioAutorizador == g.IDVoluntarioAutorizador;
                v.Regla(autorizador == null || autorizador.Estado != Constantes.VoluntarioBaja || conservaAutorizador,
                        "El voluntario autorizador está dado de baja.");
            }
            v.Lanzar();

            if (g.IDGasto == 0)
                return _dal.Insertar(g);

            _dal.Actualizar(g);
            return g.IDGasto;
        }

        public void Eliminar(int id)
        {
            _dal.Eliminar(id);
        }
    }
}
