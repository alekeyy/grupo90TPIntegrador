using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Tabla MovimientoCaja.
    /// </summary>
    public class MovimientoCaja
    {
        public int IDMovimiento { get; set; }
        public int IDCaja { get; set; }
        public DateTime Fecha { get; set; }
        public string TipoMovimiento { get; set; }
        public decimal Monto { get; set; }
        public string Concepto { get; set; }
    }
}
