using System.Collections.Generic;
using System.Data;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Acceso a datos de la tabla Equipamiento.
    /// </summary>
    public class EquipamientoDAL
    {
        private static Equipamiento Mapear(IDataRecord r)
        {
            return new Equipamiento
            {
                IDEquipamiento = r.LeerInt("IDEquipamiento"),
                CodigoInterno = r.LeerString("CodigoInterno"),
                Nombre = r.LeerString("Nombre"),
                Estado = r.LeerString("Estado"),
                FechaCompra = r.LeerFechaNull("FechaCompra"),
                FechaUltimoMantenimiento = r.LeerFechaNull("FechaUltimoMantenimiento"),
                FechaProximoMantenimiento = r.LeerFechaNull("FechaProximoMantenimiento"),
                IDTipoEquipamiento = r.LeerInt("IDTipoEquipamiento"),
                IDCategoriaEquipamiento = r.LeerInt("IDCategoriaEquipamiento"),
                TipoNombre = r.LeerString("TipoNombre"),
                CategoriaNombre = r.LeerString("CategoriaNombre")
            };
        }

        public List<Equipamiento> Listar(string texto, string estado, int? idTipo, int? idCategoria)
        {
            return SqlHelper.EjecutarLista("sp_Equipamiento_Listar", Mapear,
                SqlHelper.P("@Texto", texto),
                SqlHelper.P("@Estado", estado),
                SqlHelper.P("@IDTipoEquipamiento", idTipo),
                SqlHelper.P("@IDCategoriaEquipamiento", idCategoria));
        }

        public Equipamiento Obtener(int id)
        {
            return SqlHelper.EjecutarUno("sp_Equipamiento_Obtener", Mapear, SqlHelper.P("@IDEquipamiento", id));
        }

        public int Insertar(Equipamiento e)
        {
            return SqlHelper.EjecutarInsert("sp_Equipamiento_Insertar",
                SqlHelper.P("@CodigoInterno", e.CodigoInterno),
                SqlHelper.P("@Nombre", e.Nombre),
                SqlHelper.P("@Estado", e.Estado),
                SqlHelper.P("@FechaCompra", e.FechaCompra),
                SqlHelper.P("@FechaUltimoMantenimiento", e.FechaUltimoMantenimiento),
                SqlHelper.P("@FechaProximoMantenimiento", e.FechaProximoMantenimiento),
                SqlHelper.P("@IDTipoEquipamiento", e.IDTipoEquipamiento),
                SqlHelper.P("@IDCategoriaEquipamiento", e.IDCategoriaEquipamiento));
        }

        public void Actualizar(Equipamiento e)
        {
            SqlHelper.EjecutarNonQuery("sp_Equipamiento_Actualizar",
                SqlHelper.P("@IDEquipamiento", e.IDEquipamiento),
                SqlHelper.P("@CodigoInterno", e.CodigoInterno),
                SqlHelper.P("@Nombre", e.Nombre),
                SqlHelper.P("@Estado", e.Estado),
                SqlHelper.P("@FechaCompra", e.FechaCompra),
                SqlHelper.P("@FechaUltimoMantenimiento", e.FechaUltimoMantenimiento),
                SqlHelper.P("@FechaProximoMantenimiento", e.FechaProximoMantenimiento),
                SqlHelper.P("@IDTipoEquipamiento", e.IDTipoEquipamiento),
                SqlHelper.P("@IDCategoriaEquipamiento", e.IDCategoriaEquipamiento));
        }

        public void Eliminar(int id)
        {
            SqlHelper.EjecutarNonQuery("sp_Equipamiento_Eliminar", SqlHelper.P("@IDEquipamiento", id));
        }

        public List<ItemCombo> Combo(bool soloDisponibles)
        {
            return SqlHelper.EjecutarLista("sp_Equipamiento_Combo", VoluntarioDAL.MapearCombo,
                SqlHelper.P("@SoloDisponibles", soloDisponibles));
        }
    }
}
