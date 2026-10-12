using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Tabla HistorialRangos.
    /// </summary>
    public class HistorialRangos
    {
        public int IDHistorialRango { get; set; }
        public int IDVoluntario { get; set; }
        public int IDRango { get; set; }
        public DateTime FechaDesde { get; set; }
        public DateTime? FechaHasta { get; set; }
    }
}
