using System;
using System.Collections.Generic;
using System.Data;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Acceso a datos de la tabla HistorialRoles.
    /// </summary>
    public class HistorialRolDAL
    {
        private static HistorialRol Mapear(IDataRecord r)
        {
            return new HistorialRol
            {
                IDHistorialRol = r.LeerInt("IDHistorialRol"),
                IDVoluntario = r.LeerInt("IDVoluntario"),
                IDRol = r.LeerInt("IDRol"),
                FechaDesde = r.LeerFecha("FechaDesde"),
                FechaHasta = r.LeerFechaNull("FechaHasta"),
                VoluntarioNombre = r.LeerString("VoluntarioNombre"),
                RolNombre = r.LeerString("RolNombre")
            };
        }

        public List<HistorialRol> Listar(int? idVoluntario, bool soloVigentes)
        {
            return SqlHelper.EjecutarLista("sp_HistorialRoles_Listar", Mapear,
                SqlHelper.P("@IDVoluntario", idVoluntario),
                SqlHelper.P("@SoloVigentes", soloVigentes));
        }

        public HistorialRol Obtener(int id)
        {
            return SqlHelper.EjecutarUno("sp_HistorialRoles_Obtener", Mapear, SqlHelper.P("@IDHistorialRol", id));
        }

        public int Insertar(HistorialRol h)
        {
            return SqlHelper.EjecutarInsert("sp_HistorialRoles_Insertar",
                SqlHelper.P("@IDVoluntario", h.IDVoluntario),
                SqlHelper.P("@IDRol", h.IDRol),
                SqlHelper.P("@FechaDesde", h.FechaDesde),
                SqlHelper.P("@FechaHasta", h.FechaHasta));
        }

        public void Actualizar(HistorialRol h)
        {
            SqlHelper.EjecutarNonQuery("sp_HistorialRoles_Actualizar",
                SqlHelper.P("@IDHistorialRol", h.IDHistorialRol),
                SqlHelper.P("@IDVoluntario", h.IDVoluntario),
                SqlHelper.P("@IDRol", h.IDRol),
                SqlHelper.P("@FechaDesde", h.FechaDesde),
                SqlHelper.P("@FechaHasta", h.FechaHasta));
        }

        /// <summary>Finaliza la vigencia del rol asignando la fecha de fin.</summary>
        public void Finalizar(int id, DateTime fechaHasta)
        {
            SqlHelper.EjecutarNonQuery("sp_HistorialRoles_Finalizar",
                SqlHelper.P("@IDHistorialRol", id),
                SqlHelper.P("@FechaHasta", fechaHasta));
        }

        public void Eliminar(int id)
        {
            SqlHelper.EjecutarNonQuery("sp_HistorialRoles_Eliminar", SqlHelper.P("@IDHistorialRol", id));
        }
    }
}
