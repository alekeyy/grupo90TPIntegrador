using System;
using System.Collections.Generic;
using System.Data;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Acceso a datos de la tabla Aportes.
    /// </summary>
    public class AporteDAL
    {
        private static Aporte Mapear(IDataRecord r)
        {
            return new Aporte
            {
                IDAporte = r.LeerInt("IDAporte"),
                IDTipoAporte = r.LeerInt("IDTipoAporte"),
                Fecha = r.LeerFecha("Fecha"),
                Monto = r.LeerDecimal("Monto"),
                Descripcion = r.LeerString("Descripcion"),
                TipoNombre = r.LeerString("TipoNombre")
            };
        }

        public List<Aporte> Listar(DateTime? desde, DateTime? hasta, int? idTipoAporte)
        {
            return SqlHelper.EjecutarLista("sp_Aportes_Listar", Mapear,
                SqlHelper.P("@Desde", desde),
                SqlHelper.P("@Hasta", hasta),
                SqlHelper.P("@IDTipoAporte", idTipoAporte));
        }

        public Aporte Obtener(int id)
        {
            return SqlHelper.EjecutarUno("sp_Aportes_Obtener", Mapear, SqlHelper.P("@IDAporte", id));
        }

        public int Insertar(Aporte a)
        {
            return SqlHelper.EjecutarInsert("sp_Aportes_Insertar",
                SqlHelper.P("@IDTipoAporte", a.IDTipoAporte),
                SqlHelper.P("@Fecha", a.Fecha),
                SqlHelper.P("@Monto", a.Monto),
                SqlHelper.P("@Descripcion", a.Descripcion));
        }

        public void Actualizar(Aporte a)
        {
            SqlHelper.EjecutarNonQuery("sp_Aportes_Actualizar",
                SqlHelper.P("@IDAporte", a.IDAporte),
                SqlHelper.P("@IDTipoAporte", a.IDTipoAporte),
                SqlHelper.P("@Fecha", a.Fecha),
                SqlHelper.P("@Monto", a.Monto),
                SqlHelper.P("@Descripcion", a.Descripcion));
        }

        public void Eliminar(int id)
        {
            SqlHelper.EjecutarNonQuery("sp_Aportes_Eliminar", SqlHelper.P("@IDAporte", id));
        }
    }
}
