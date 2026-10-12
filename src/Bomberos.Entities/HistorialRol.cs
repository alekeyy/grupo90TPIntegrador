using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Período en el que un voluntario desempeñó un rol (tabla HistorialRoles).
    /// FechaHasta = null indica que el rol está vigente.
    /// </summary>
    [Serializable]
    public class HistorialRol
    {
        public int IDHistorialRol { get; set; }
        public int IDVoluntario { get; set; }
        public int IDRol { get; set; }
        public DateTime FechaDesde { get; set; }
        public DateTime? FechaHasta { get; set; }

        public string VoluntarioNombre { get; set; }
        public string RolNombre { get; set; }

        public bool Vigente
        {
            get { return !FechaHasta.HasValue; }
        }
    }
}
