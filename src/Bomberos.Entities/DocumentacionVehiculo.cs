using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Tabla DocumentacionVehiculo.
    /// </summary>
    public class DocumentacionVehiculo
    {
        public int IDDocumento { get; set; }
        public int IDVehiculo { get; set; }
        public string TipoDocumento { get; set; }
        public DateTime FechaEmision { get; set; }
        public DateTime FechaVencimiento { get; set; }
        public string Estado { get; set; }
    }
}
