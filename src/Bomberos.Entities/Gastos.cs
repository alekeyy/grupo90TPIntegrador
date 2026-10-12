using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Tabla Gastos.
    /// </summary>
    public class Gastos
    {
        public int IDGasto { get; set; }
        public DateTime Fecha { get; set; }
        public decimal Monto { get; set; }
        public string Descripcion { get; set; }
        public int IDTipoGasto { get; set; }
        public int IDVoluntarioAutorizador { get; set; }
    }
}
