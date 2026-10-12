using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Tabla Aportes.
    /// </summary>
    public class Aportes
    {
        public int IDAporte { get; set; }
        public int IDTipoAporte { get; set; }
        public DateTime Fecha { get; set; }
        public decimal Monto { get; set; }
        public string Descripcion { get; set; }
    }
}
