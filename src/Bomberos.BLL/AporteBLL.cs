using System;
using System.Collections.Generic;
using Bomberos.DAL;
using Bomberos.Entities;

namespace Bomberos.BLL
{
    /// <summary>
    /// Reglas de negocio de Aportes.
    /// </summary>
    public class AporteBLL
    {
        public const decimal MontoMaximo = 9999999999.99m;   // DECIMAL(12,2)
        private readonly AporteDAL _dal = new AporteDAL();

        public List<Aporte> Listar(DateTime? desde, DateTime? hasta, int? idTipoAporte)
        {
            if (desde.HasValue && hasta.HasValue && desde > hasta)
                throw new ValidacionException("La fecha 'desde' no puede ser posterior a la fecha 'hasta'.");
            return _dal.Listar(desde, hasta, idTipoAporte);
        }

        public Aporte Obtener(int id)
        {
            return _dal.Obtener(id);
        }

        public int Guardar(Aporte a)
        {
            a.Descripcion = Texto.Normalizar(a.Descripcion);

            new Validador()
                .Seleccionado(a.IDTipoAporte, "un tipo de aporte")
                .FechaValida(a.Fecha, "Fecha")
                .Regla(a.Fecha.Date <= DateTime.Today, "La fecha del aporte no puede ser futura.")
                .Regla(a.Monto > 0, "El monto debe ser mayor a cero.")
                .Regla(a.Monto <= MontoMaximo, "El monto supera el máximo permitido.")
                .LongitudMaxima(a.Descripcion, 250, "Descripción")
                .Lanzar();

            if (a.IDAporte == 0)
                return _dal.Insertar(a);

            _dal.Actualizar(a);
            return a.IDAporte;
        }

        public void Eliminar(int id)
        {
            _dal.Eliminar(id);
        }
    }
}
