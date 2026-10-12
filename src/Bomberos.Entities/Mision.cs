using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Misión generada a partir de un incidente (tabla Misiones).
    /// </summary>
    [Serializable]
    public class Mision
    {
        public int IDMision { get; set; }
        public int IDIncidente { get; set; }
        public int IDTipoMision { get; set; }
        public string Nombre { get; set; }
        public DateTime FechaInicio { get; set; }
        public DateTime? FechaFin { get; set; }
        public string Estado { get; set; }

        public string IncidenteDireccion { get; set; }
        public DateTime IncidenteFechaHora { get; set; }
        public string IncidenteSeveridad { get; set; }
        public string TipoMisionNombre { get; set; }
        public int CantidadVoluntarios { get; set; }
        public int CantidadVehiculos { get; set; }
        public int CantidadEquipamiento { get; set; }

        /// <summary>Duración de la misión (hasta ahora si sigue en curso).</summary>
        public TimeSpan Duracion
        {
            get { return (FechaFin ?? DateTime.Now) - FechaInicio; }
        }
    }

    /// <summary>
    /// Recurso (voluntario, vehículo o equipo) asignado a una misión.
    /// </summary>
    [Serializable]
    public class RecursoAsignado
    {
        public int ID { get; set; }
        public string Descripcion { get; set; }
        public string Detalle { get; set; }
        public string Estado { get; set; }
    }

    /// <summary>
    /// Tipos de recurso que se pueden asignar a una misión.
    /// Cada uno corresponde a una tabla intermedia (MisionVoluntario, MisionVehiculo, MisionEquipamiento).
    /// </summary>
    public enum TipoRecurso
    {
        Voluntario,
        Vehiculo,
        Equipamiento
    }
}
