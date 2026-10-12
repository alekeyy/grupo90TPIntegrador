using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Tabla Vehiculos.
    /// </summary>
    public class Vehiculos
    {
        public int IDVehiculo { get; set; }
        public string Nombre { get; set; }
        // Columna [Año] en la base de datos
        public int Anio { get; set; }
        public string Patente { get; set; }
        public string Estado { get; set; }
        public int IDTipoVehiculo { get; set; }
    }
}
