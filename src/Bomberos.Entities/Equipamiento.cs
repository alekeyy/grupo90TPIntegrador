using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Tabla Equipamiento.
    /// </summary>
    public class Equipamiento
    {
        public int IDEquipamiento { get; set; }
        public string CodigoInterno { get; set; }
        public string Nombre { get; set; }
        public string Estado { get; set; }
        public DateTime? FechaCompra { get; set; }
        public DateTime? FechaUltimoMantenimiento { get; set; }
        public DateTime? FechaProximoMantenimiento { get; set; }
        public int IDTipoEquipamiento { get; set; }
        public int IDCategoriaEquipamiento { get; set; }
    }
}
