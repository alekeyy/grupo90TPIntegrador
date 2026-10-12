using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Tabla Incidentes.
    /// </summary>
    public class Incidentes
    {
        public int IDIncidente { get; set; }
        public DateTime FechaHora { get; set; }
        public string Direccion { get; set; }
        public string Descripcion { get; set; }
        public string Severidad { get; set; }
    }
}
