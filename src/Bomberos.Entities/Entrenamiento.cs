using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Entrenamiento realizado por un voluntario (tabla Entrenamientos).
    /// </summary>
    [Serializable]
    public class Entrenamiento
    {
        public int IDEntrenamiento { get; set; }
        public int IDTipoEntrenamiento { get; set; }
        public int IDVoluntario { get; set; }
        public DateTime Fecha { get; set; }
        public string Observaciones { get; set; }

        public string TipoNombre { get; set; }
        public string VoluntarioNombre { get; set; }
    }
}
