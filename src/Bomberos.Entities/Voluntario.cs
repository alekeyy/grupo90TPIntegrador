using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Voluntario del cuartel (tabla Voluntarios).
    /// </summary>
    [Serializable]
    public class Voluntario
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

        /// <summary>Nombre del rango vigente (solo lectura, calculado por la consulta).</summary>
        public string RangoActual { get; set; }

        public string NombreCompleto
        {
            get { return Apellido + ", " + Nombre; }
        }

        public int Edad
        {
            get
            {
                DateTime hoy = DateTime.Today;
                int edad = hoy.Year - FechaNacimiento.Year;
                if (FechaNacimiento.Date > hoy.AddYears(-edad)) edad--;
                return edad;
            }
        }
    }
}
