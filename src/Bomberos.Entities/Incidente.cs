using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Incidente o emergencia reportada (tabla Incidentes).
    /// </summary>
    [Serializable]
    public class Incidente
    {
        public int IDIncidente { get; set; }
        public DateTime FechaHora { get; set; }
        public string Direccion { get; set; }
        public string Descripcion { get; set; }
        public string Severidad { get; set; }

        public int CantidadMisiones { get; set; }
    }
}
