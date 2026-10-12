using System;
using System.Collections.Generic;
using Bomberos.DAL;
using Bomberos.Entities;

namespace Bomberos.BLL
{
    /// <summary>
    /// Reglas de negocio de Incidentes.
    /// </summary>
    public class IncidenteBLL
    {
        private readonly IncidenteDAL _dal = new IncidenteDAL();

        public List<Incidente> Listar(DateTime? desde, DateTime? hasta, string severidad, string texto)
        {
            if (desde.HasValue && hasta.HasValue && desde > hasta)
                throw new ValidacionException("La fecha 'desde' no puede ser posterior a la fecha 'hasta'.");
            return _dal.Listar(desde, hasta, Texto.Normalizar(severidad), Texto.Normalizar(texto));
        }

        public Incidente Obtener(int id)
        {
            return _dal.Obtener(id);
        }

        public List<ItemCombo> Combo()
        {
            return _dal.Combo();
        }

        public int Guardar(Incidente i)
        {
            i.Direccion = Texto.Normalizar(i.Direccion);
            i.Descripcion = Texto.Normalizar(i.Descripcion);
            i.Severidad = Texto.Normalizar(i.Severidad);

            new Validador()
                .FechaValida(i.FechaHora, "Fecha y hora")
                .Regla(i.FechaHora <= DateTime.Now.AddMinutes(5), "La fecha y hora del incidente no puede ser futura.")
                .Requerido(i.Direccion, "Dirección").LongitudMaxima(i.Direccion, 200, "Dirección")
                .LongitudMaxima(i.Descripcion, 500, "Descripción")
                .EnLista(i.Severidad, Constantes.Severidades, "Severidad")
                .Lanzar();

            if (i.IDIncidente == 0)
                return _dal.Insertar(i);

            _dal.Actualizar(i);
            return i.IDIncidente;
        }

        public void Eliminar(int id)
        {
            _dal.Eliminar(id);
        }
    }
}
