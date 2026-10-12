using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Ejecuta los Stored Procedures de reportes (sp_Rpt_*) y devuelve un DataTable.
    /// Los parámetros se agregan según la definición del reporte.
    /// </summary>
    public class ReporteDAL
    {
        public DataTable Ejecutar(ReporteDefinicion definicion, FiltroReporte filtro)
        {
            List<SqlParameter> p = new List<SqlParameter>();

            if (definicion.Usa(ParametroReporte.Periodo))
            {
                p.Add(SqlHelper.P("@Desde", filtro.Desde));
                p.Add(SqlHelper.P("@Hasta", filtro.Hasta));
            }
            if (definicion.Usa(ParametroReporte.Voluntario))
                p.Add(SqlHelper.P("@IDVoluntario", filtro.IDVoluntario));
            if (definicion.Usa(ParametroReporte.EstadoMision) || definicion.Usa(ParametroReporte.EstadoEquipo))
                p.Add(SqlHelper.P("@Estado", filtro.Estado));
            if (definicion.Usa(ParametroReporte.Caja))
                p.Add(SqlHelper.P("@IDCaja", filtro.IDCaja));
            if (definicion.Usa(ParametroReporte.Anio))
                p.Add(SqlHelper.P("@Anio", filtro.Anio));
            if (definicion.Usa(ParametroReporte.Dias))
                p.Add(SqlHelper.P("@Dias", filtro.Dias ?? definicion.DiasPorDefecto));

            return SqlHelper.EjecutarDataTable(definicion.StoredProcedure, p.ToArray());
        }
    }
}
