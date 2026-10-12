using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Período en el que un voluntario ostentó un rango (tabla HistorialRangos).
    /// FechaHasta = null indica el rango vigente.
    /// </summary>
    [Serializable]
    public class HistorialRango
    {
        public int IDHistorialRango { get; set; }
        public int IDVoluntario { get; set; }
        public int IDRango { get; set; }
        public DateTime FechaDesde { get; set; }
        public DateTime? FechaHasta { get; set; }

        public string VoluntarioNombre { get; set; }
        public string RangoNombre { get; set; }

        public bool Vigente
        {
            get { return !FechaHasta.HasValue; }
        }
    }
}
