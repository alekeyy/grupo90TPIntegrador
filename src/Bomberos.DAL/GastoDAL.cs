using System;
using System.Collections.Generic;
using System.Data;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Acceso a datos de la tabla Gastos.
    /// </summary>
    public class GastoDAL
    {
        private static Gasto Mapear(IDataRecord r)
        {
            return new Gasto
            {
                IDGasto = r.LeerInt("IDGasto"),
                Fecha = r.LeerFecha("Fecha"),
                Monto = r.LeerDecimal("Monto"),
                Descripcion = r.LeerString("Descripcion"),
                IDTipoGasto = r.LeerInt("IDTipoGasto"),
                IDVoluntarioAutorizador = r.LeerInt("IDVoluntarioAutorizador"),
                TipoNombre = r.LeerString("TipoNombre"),
                AutorizadorNombre = r.LeerString("AutorizadorNombre")
            };
        }

        public List<Gasto> Listar(DateTime? desde, DateTime? hasta, int? idTipoGasto, int? idVoluntario)
        {
            return SqlHelper.EjecutarLista("sp_Gastos_Listar", Mapear,
                SqlHelper.P("@Desde", desde),
                SqlHelper.P("@Hasta", hasta),
                SqlHelper.P("@IDTipoGasto", idTipoGasto),
                SqlHelper.P("@IDVoluntario", idVoluntario));
        }

        public Gasto Obtener(int id)
        {
            return SqlHelper.EjecutarUno("sp_Gastos_Obtener", Mapear, SqlHelper.P("@IDGasto", id));
        }

        public int Insertar(Gasto g)
        {
            return SqlHelper.EjecutarInsert("sp_Gastos_Insertar",
                SqlHelper.P("@Fecha", g.Fecha),
                SqlHelper.P("@Monto", g.Monto),
                SqlHelper.P("@Descripcion", g.Descripcion),
                SqlHelper.P("@IDTipoGasto", g.IDTipoGasto),
                SqlHelper.P("@IDVoluntarioAutorizador", g.IDVoluntarioAutorizador));
        }

        public void Actualizar(Gasto g)
        {
            SqlHelper.EjecutarNonQuery("sp_Gastos_Actualizar",
                SqlHelper.P("@IDGasto", g.IDGasto),
                SqlHelper.P("@Fecha", g.Fecha),
                SqlHelper.P("@Monto", g.Monto),
                SqlHelper.P("@Descripcion", g.Descripcion),
                SqlHelper.P("@IDTipoGasto", g.IDTipoGasto),
                SqlHelper.P("@IDVoluntarioAutorizador", g.IDVoluntarioAutorizador));
        }

        public void Eliminar(int id)
        {
            SqlHelper.EjecutarNonQuery("sp_Gastos_Eliminar", SqlHelper.P("@IDGasto", id));
        }
    }
}
