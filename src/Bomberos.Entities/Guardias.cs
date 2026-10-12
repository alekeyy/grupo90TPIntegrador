using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Tabla Guardias.
    /// </summary>
    public class Guardias
    {
        public int IDGuardia { get; set; }
        public int IDVoluntario { get; set; }
        public DateTime Fecha { get; set; }
        public TimeSpan HoraInicio { get; set; }
        public TimeSpan HoraFin { get; set; }
    }
}
