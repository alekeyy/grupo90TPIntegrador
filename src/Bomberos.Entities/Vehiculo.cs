using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Vehículo del cuartel (tabla Vehiculos). La columna [Año] se mapea como Anio.
    /// </summary>
    [Serializable]
    public class Vehiculo
    {
        public int IDVehiculo { get; set; }
        public string Nombre { get; set; }
        public int Anio { get; set; }
        public string Patente { get; set; }
        public string Estado { get; set; }
        public int IDTipoVehiculo { get; set; }

        public string TipoNombre { get; set; }
        public int DocumentosVencidos { get; set; }
    }
}
