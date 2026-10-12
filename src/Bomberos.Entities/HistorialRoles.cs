using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Tabla HistorialRoles.
    /// </summary>
    public class HistorialRoles
    {
        public int IDHistorialRol { get; set; }
        public int IDVoluntario { get; set; }
        public int IDRol { get; set; }
        public DateTime FechaDesde { get; set; }
        public DateTime? FechaHasta { get; set; }
    }
}
