using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Tabla Entrenamientos.
    /// </summary>
    public class Entrenamientos
    {
        public int IDEntrenamiento { get; set; }
        public int IDTipoEntrenamiento { get; set; }
        public int IDVoluntario { get; set; }
        public DateTime Fecha { get; set; }
        public string Observaciones { get; set; }
    }
}
