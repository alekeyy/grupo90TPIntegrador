using System;
using System.Collections.Generic;
using Bomberos.DAL;
using Bomberos.Entities;

namespace Bomberos.BLL
{
    /// <summary>
    /// Reglas de negocio de los movimientos de caja.
    /// TipoMovimiento admite únicamente "Ingreso" o "Egreso".
    /// </summary>
    public class MovimientoCajaBLL
    {
        private readonly MovimientoCajaDAL _dal = new MovimientoCajaDAL();

        public List<MovimientoCaja> Listar(int? idCaja, DateTime? desde, DateTime? hasta, string tipoMovimiento)
        {
            if (desde.HasValue && hasta.HasValue && desde > hasta)
                throw new ValidacionException("La fecha 'desde' no puede ser posterior a la fecha 'hasta'.");
            return _dal.Listar(idCaja, desde, hasta, Texto.Normalizar(tipoMovimiento));
        }

        public MovimientoCaja Obtener(int id)
        {
            return _dal.Obtener(id);
        }

        public List<CajaSaldo> Saldos()
        {
            return _dal.Saldos();
        }

        public int Guardar(MovimientoCaja m)
        {
            m.Concepto = Texto.Normalizar(m.Concepto);
            m.TipoMovimiento = Texto.Normalizar(m.TipoMovimiento);

            new Validador()
                .Seleccionado(m.IDCaja, "una caja")
                .FechaValida(m.Fecha, "Fecha")
                .Regla(m.Fecha <= DateTime.Now.AddMinutes(5), "La fecha del movimiento no puede ser futura.")
                .EnLista(m.TipoMovimiento, Constantes.TiposMovimiento, "Tipo de movimiento")
                .Regla(m.Monto > 0, "El monto debe ser mayor a cero.")
                .Regla(m.Monto <= AporteBLL.MontoMaximo, "El monto supera el máximo permitido.")
                .LongitudMaxima(m.Concepto, 250, "Concepto")
                .Lanzar();

            // El control de saldo suficiente para egresos se realiza en sp_MovimientoCaja_Validar.
            if (m.IDMovimiento == 0)
                return _dal.Insertar(m);

            _dal.Actualizar(m);
            return m.IDMovimiento;
        }

        public void Eliminar(int id)
        {
            _dal.Eliminar(id);
        }
    }
}
