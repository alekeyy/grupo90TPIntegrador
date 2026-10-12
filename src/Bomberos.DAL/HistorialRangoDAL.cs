using System;
using System.Collections.Generic;
using System.Data;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Acceso a datos de la tabla HistorialRangos.
    /// </summary>
    public class HistorialRangoDAL
    {
        private static HistorialRango Mapear(IDataRecord r)
        {
            return new HistorialRango
            {
                IDHistorialRango = r.LeerInt("IDHistorialRango"),
                IDVoluntario = r.LeerInt("IDVoluntario"),
                IDRango = r.LeerInt("IDRango"),
                FechaDesde = r.LeerFecha("FechaDesde"),
                FechaHasta = r.LeerFechaNull("FechaHasta"),
                VoluntarioNombre = r.LeerString("VoluntarioNombre"),
                RangoNombre = r.LeerString("RangoNombre")
            };
        }

        public List<HistorialRango> Listar(int? idVoluntario, bool soloVigentes)
        {
            return SqlHelper.EjecutarLista("sp_HistorialRangos_Listar", Mapear,
                SqlHelper.P("@IDVoluntario", idVoluntario),
                SqlHelper.P("@SoloVigentes", soloVigentes));
        }

        public HistorialRango Obtener(int id)
        {
            return SqlHelper.EjecutarUno("sp_HistorialRangos_Obtener", Mapear, SqlHelper.P("@IDHistorialRango", id));
        }

        public int Insertar(HistorialRango h)
        {
            return SqlHelper.EjecutarInsert("sp_HistorialRangos_Insertar",
                SqlHelper.P("@IDVoluntario", h.IDVoluntario),
                SqlHelper.P("@IDRango", h.IDRango),
                SqlHelper.P("@FechaDesde", h.FechaDesde),
                SqlHelper.P("@FechaHasta", h.FechaHasta));
        }

        public void Actualizar(HistorialRango h)
        {
            SqlHelper.EjecutarNonQuery("sp_HistorialRangos_Actualizar",
                SqlHelper.P("@IDHistorialRango", h.IDHistorialRango),
                SqlHelper.P("@IDVoluntario", h.IDVoluntario),
                SqlHelper.P("@IDRango", h.IDRango),
                SqlHelper.P("@FechaDesde", h.FechaDesde),
                SqlHelper.P("@FechaHasta", h.FechaHasta));
        }

        public void Eliminar(int id)
        {
            SqlHelper.EjecutarNonQuery("sp_HistorialRangos_Eliminar", SqlHelper.P("@IDHistorialRango", id));
        }

        /// <summary>
        /// Registra un ascenso (cierra el rango vigente y abre el nuevo en una transacción).
        /// </summary>
        public int Ascender(int idVoluntario, int idRango, DateTime fecha)
        {
            return SqlHelper.EjecutarInsert("sp_HistorialRangos_Ascender",
                SqlHelper.P("@IDVoluntario", idVoluntario),
                SqlHelper.P("@IDRango", idRango),
                SqlHelper.P("@Fecha", fecha));
        }
    }
}
