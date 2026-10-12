using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Movimiento (ingreso o egreso) de una caja (tabla MovimientoCaja).
    /// </summary>
    [Serializable]
    public class MovimientoCaja
    {
        public int IDMovimiento { get; set; }
        public int IDCaja { get; set; }
        public DateTime Fecha { get; set; }
        public string TipoMovimiento { get; set; }
        public decimal Monto { get; set; }
        public string Concepto { get; set; }

        public string CajaNombre { get; set; }

        /// <summary>Monto con signo: positivo para ingresos, negativo para egresos.</summary>
        public decimal MontoConSigno
        {
            get { return TipoMovimiento == Constantes.MovimientoEgreso ? -Monto : Monto; }
        }
    }

    /// <summary>
    /// Saldo calculado de una caja.
    /// </summary>
    [Serializable]
    public class CajaSaldo
    {
        public int IDCaja { get; set; }
        public string Nombre { get; set; }
        public decimal TotalIngresos { get; set; }
        public decimal TotalEgresos { get; set; }
        public decimal Saldo { get; set; }
        public int CantidadMovimientos { get; set; }
    }
}
