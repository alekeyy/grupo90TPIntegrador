namespace Bomberos.Entities
{
    /// <summary>
    /// Valores de dominio utilizados en todo el sistema (estados, severidades, tipos).
    /// Se centralizan aquí para que la UI y la capa de negocio usen los mismos valores.
    /// </summary>
    public static class Constantes
    {
        // Voluntarios
        public const string VoluntarioActivo = "Activo";
        public const string VoluntarioBaja = "Baja";
        public static readonly string[] EstadosVoluntario = { "Activo", "Licencia", "Inactivo", "Baja" };

        // Vehículos
        public const string VehiculoOperativo = "Operativo";
        public static readonly string[] EstadosVehiculo = { "Operativo", "En mantenimiento", "Fuera de servicio" };
        public static readonly string[] TiposDocumentoVehiculo = { "VTV", "Seguro", "Habilitación", "Inspección técnica", "Cédula", "Otro" };

        /// <summary>Días de anticipación para considerar un documento "próximo a vencer".</summary>
        public const int DiasAvisoVencimiento = 30;

        // Equipamiento
        public const string EquipoDisponible = "Disponible";
        public static readonly string[] EstadosEquipamiento = { "Disponible", "En uso", "En mantenimiento", "Fuera de servicio", "Baja" };

        // Operaciones
        public static readonly string[] Severidades = { "Baja", "Media", "Alta", "Critica" };
        public const string MisionEnCurso = "En curso";
        public const string MisionFinalizada = "Finalizada";
        public const string MisionCancelada = "Cancelada";
        public static readonly string[] EstadosMision = { MisionEnCurso, MisionFinalizada, MisionCancelada };

        // Finanzas
        public const string MovimientoIngreso = "Ingreso";
        public const string MovimientoEgreso = "Egreso";
        public static readonly string[] TiposMovimiento = { MovimientoIngreso, MovimientoEgreso };
    }
}
