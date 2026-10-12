using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Tabla Misiones.
    /// </summary>
    public class Misiones
    {
        public int IDMision { get; set; }
        public int IDIncidente { get; set; }
        public int IDTipoMision { get; set; }
        public string Nombre { get; set; }
        public DateTime FechaInicio { get; set; }
        public DateTime? FechaFin { get; set; }
        public string Estado { get; set; }
    }
}
