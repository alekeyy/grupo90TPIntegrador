using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Documentación asociada a un vehículo: VTV, seguro, habilitación, etc.
    /// (tabla DocumentacionVehiculo).
    /// </summary>
    [Serializable]
    public class DocumentoVehiculo
    {
        public int IDDocumento { get; set; }
        public int IDVehiculo { get; set; }
        public string TipoDocumento { get; set; }
        public DateTime FechaEmision { get; set; }
        public DateTime FechaVencimiento { get; set; }
        public string Estado { get; set; }

        public string VehiculoNombre { get; set; }
        public string Patente { get; set; }

        /// <summary>Días que faltan para el vencimiento (negativo si ya venció).</summary>
        public int DiasParaVencer { get; set; }

        /// <summary>Vigente | Próximo a vencer | Vencido (calculado según la fecha actual).</summary>
        public string Situacion { get; set; }
    }
}
