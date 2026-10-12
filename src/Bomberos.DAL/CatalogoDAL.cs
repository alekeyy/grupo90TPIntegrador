using System.Collections.Generic;
using System.Data;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Acceso a datos de los catálogos simples (Rangos, Roles, tipos, categorías y cajas).
    /// El nombre del SP se arma a partir del tipo de catálogo: sp_[Tabla]_[Operación].
    /// El enum TipoCatalogo actúa como lista blanca, por lo que no hay riesgo de inyección.
    /// </summary>
    public class CatalogoDAL
    {
        private static string Sp(TipoCatalogo tipo, string operacion)
        {
            return "sp_" + tipo.ToString() + "_" + operacion;
        }

        private static Catalogo Mapear(IDataRecord r)
        {
            return new Catalogo
            {
                ID = r.LeerInt("ID"),
                Nombre = r.LeerString("Nombre"),
                Descripcion = r.LeerString("Descripcion"),
                CantidadRegistros = r.LeerInt("CantidadRegistros")
            };
        }

        public List<Catalogo> Listar(TipoCatalogo tipo, string texto)
        {
            return SqlHelper.EjecutarLista(Sp(tipo, "Listar"), Mapear, SqlHelper.P("@Texto", texto));
        }

        public Catalogo Obtener(TipoCatalogo tipo, int id)
        {
            return SqlHelper.EjecutarUno(Sp(tipo, "Obtener"), Mapear, SqlHelper.P("@ID", id));
        }

        public int Insertar(TipoCatalogo tipo, Catalogo item)
        {
            return SqlHelper.EjecutarInsert(Sp(tipo, "Insertar"),
                SqlHelper.P("@Nombre", item.Nombre),
                SqlHelper.P("@Descripcion", item.Descripcion));
        }

        public void Actualizar(TipoCatalogo tipo, Catalogo item)
        {
            SqlHelper.EjecutarNonQuery(Sp(tipo, "Actualizar"),
                SqlHelper.P("@ID", item.ID),
                SqlHelper.P("@Nombre", item.Nombre),
                SqlHelper.P("@Descripcion", item.Descripcion));
        }

        public void Eliminar(TipoCatalogo tipo, int id)
        {
            SqlHelper.EjecutarNonQuery(Sp(tipo, "Eliminar"), SqlHelper.P("@ID", id));
        }
    }
}
