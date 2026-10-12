using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Parámetros que puede requerir un reporte. Se combinan como flags.
    /// </summary>
    [Flags]
    public enum ParametroReporte
    {
        Ninguno = 0,
        Periodo = 1,        // @Desde / @Hasta
        Voluntario = 2,     // @IDVoluntario
        EstadoMision = 4,   // @Estado (estados de misión)
        EstadoEquipo = 8,   // @Estado (estados de equipamiento)
        Caja = 16,          // @IDCaja
        Anio = 32,          // @Anio
        Dias = 64           // @Dias
    }

    /// <summary>
    /// Definición de un reporte: título, categoría, Stored Procedure y parámetros que utiliza.
    /// </summary>
    public class ReporteDefinicion
    {
        public string Clave { get; set; }
        public string Categoria { get; set; }
        public string Titulo { get; set; }
        public string Descripcion { get; set; }
        public string StoredProcedure { get; set; }
        public ParametroReporte Parametros { get; set; }

        /// <summary>Valor por defecto del parámetro @Dias.</summary>
        public int DiasPorDefecto { get; set; }

        public bool Usa(ParametroReporte parametro)
        {
            return (Parametros & parametro) == parametro;
        }
    }

    /// <summary>
    /// Valores de filtro ingresados por el usuario para ejecutar un reporte.
    /// </summary>
    public class FiltroReporte
    {
        public DateTime? Desde { get; set; }
        public DateTime? Hasta { get; set; }
        public int? IDVoluntario { get; set; }
        public string Estado { get; set; }
        public int? IDCaja { get; set; }
        public int? Anio { get; set; }
        public int? Dias { get; set; }
    }
}
