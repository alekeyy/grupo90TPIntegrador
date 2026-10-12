using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Tabla Voluntarios.
    /// </summary>
    public class Voluntarios
    {
        public int IDVoluntario { get; set; }
        public string Nombre { get; set; }
        public string Apellido { get; set; }
        public string DNI { get; set; }
        public DateTime FechaNacimiento { get; set; }
        public string Telefono { get; set; }
        public string Email { get; set; }
        public string Direccion { get; set; }
        public DateTime FechaIngreso { get; set; }
        public string Estado { get; set; }
    }
}
