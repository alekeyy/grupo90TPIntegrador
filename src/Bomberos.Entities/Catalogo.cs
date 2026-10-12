using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Catálogos simples del sistema (tablas con ID + Nombre).
    /// Cada valor corresponde a una tabla y a un juego de Stored Procedures sp_[Tabla]_*.
    /// </summary>
    public enum TipoCatalogo
    {
        Rangos,
        Roles,
        TipoVehiculo,
        TipoEquipamiento,
        CategoriaEquipamiento,
        TipoMision,
        TipoEntrenamiento,
        TipoAporte,
        TipoGasto,
        Caja
    }

    /// <summary>
    /// Registro genérico de catálogo. Descripcion solo se utiliza en TipoMision.
    /// </summary>
    [Serializable]
    public class Catalogo
    {
        public int ID { get; set; }
        public string Nombre { get; set; }
        public string Descripcion { get; set; }

        /// <summary>Cantidad de registros que referencian a este ítem (informativo).</summary>
        public int CantidadRegistros { get; set; }
    }
}
