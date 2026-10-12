using System;
using System.Collections.Generic;
using System.Data;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Acceso a datos de la tabla Incidentes.
    /// </summary>
    public class IncidenteDAL
    {
        private static Incidente Mapear(IDataRecord r)
        {
            return new Incidente
            {
                IDIncidente = r.LeerInt("IDIncidente"),
                FechaHora = r.LeerFecha("FechaHora"),
                Direccion = r.LeerString("Direccion"),
                Descripcion = r.LeerString("Descripcion"),
                Severidad = r.LeerString("Severidad"),
                CantidadMisiones = r.LeerInt("CantidadMisiones")
            };
        }

        public List<Incidente> Listar(DateTime? desde, DateTime? hasta, string severidad, string texto)
        {
            return SqlHelper.EjecutarLista("sp_Incidentes_Listar", Mapear,
                SqlHelper.P("@Desde", desde),
                SqlHelper.P("@Hasta", hasta),
                SqlHelper.P("@Severidad", severidad),
                SqlHelper.P("@Texto", texto));
        }

        public Incidente Obtener(int id)
        {
            return SqlHelper.EjecutarUno("sp_Incidentes_Obtener", Mapear, SqlHelper.P("@IDIncidente", id));
        }

        public int Insertar(Incidente i)
        {
            return SqlHelper.EjecutarInsert("sp_Incidentes_Insertar",
                SqlHelper.P("@FechaHora", i.FechaHora),
                SqlHelper.P("@Direccion", i.Direccion),
                SqlHelper.P("@Descripcion", i.Descripcion),
                SqlHelper.P("@Severidad", i.Severidad));
        }

        public void Actualizar(Incidente i)
        {
            SqlHelper.EjecutarNonQuery("sp_Incidentes_Actualizar",
                SqlHelper.P("@IDIncidente", i.IDIncidente),
                SqlHelper.P("@FechaHora", i.FechaHora),
                SqlHelper.P("@Direccion", i.Direccion),
                SqlHelper.P("@Descripcion", i.Descripcion),
                SqlHelper.P("@Severidad", i.Severidad));
        }

        public void Eliminar(int id)
        {
            SqlHelper.EjecutarNonQuery("sp_Incidentes_Eliminar", SqlHelper.P("@IDIncidente", id));
        }

        public List<ItemCombo> Combo()
        {
            return SqlHelper.EjecutarLista("sp_Incidentes_Combo", VoluntarioDAL.MapearCombo);
        }
    }
}
