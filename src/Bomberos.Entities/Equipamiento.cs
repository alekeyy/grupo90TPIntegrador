using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Equipo o herramienta del cuartel (tabla Equipamiento).
    /// </summary>
    [Serializable]
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

        public string TipoNombre { get; set; }
        public string CategoriaNombre { get; set; }

        /// <summary>Indica si el mantenimiento programado está vencido.</summary>
        public bool MantenimientoVencido
        {
            get { return FechaProximoMantenimiento.HasValue && FechaProximoMantenimiento.Value.Date < DateTime.Today; }
        }
    }
}
