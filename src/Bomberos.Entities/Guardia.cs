using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Guardia cumplida por un voluntario (tabla Guardias).
    /// Si HoraFin es menor o igual a HoraInicio, la guardia termina al día siguiente.
    /// </summary>
    [Serializable]
    public class Guardia
    {
        public int IDGuardia { get; set; }
        public int IDVoluntario { get; set; }
        public DateTime Fecha { get; set; }
        public TimeSpan HoraInicio { get; set; }
        public TimeSpan HoraFin { get; set; }

        public string VoluntarioNombre { get; set; }

        /// <summary>Indica si la guardia está transcurriendo en este momento.</summary>
        public bool EnCurso { get; set; }

        public bool TerminaDiaSiguiente
        {
            get { return HoraFin <= HoraInicio; }
        }

        public double DuracionHoras
        {
            get
            {
                TimeSpan d = HoraFin - HoraInicio;
                if (d <= TimeSpan.Zero) d = d.Add(TimeSpan.FromDays(1));
                return d.TotalHours;
            }
        }
    }
}
