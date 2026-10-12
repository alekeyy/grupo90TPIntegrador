using System.Collections.Generic;
using System.Data;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Acceso a datos de la tabla Voluntarios.
    /// </summary>
    public class VoluntarioDAL
    {
        private static Voluntario Mapear(IDataRecord r)
        {
            return new Voluntario
            {
                IDVoluntario = r.LeerInt("IDVoluntario"),
                Nombre = r.LeerString("Nombre"),
                Apellido = r.LeerString("Apellido"),
                DNI = r.LeerString("DNI"),
                FechaNacimiento = r.LeerFecha("FechaNacimiento"),
                Telefono = r.LeerString("Telefono"),
                Email = r.LeerString("Email"),
                Direccion = r.LeerString("Direccion"),
                FechaIngreso = r.LeerFecha("FechaIngreso"),
                Estado = r.LeerString("Estado"),
                RangoActual = r.LeerString("RangoActual")
            };
        }

        internal static ItemCombo MapearCombo(IDataRecord r)
        {
            return new ItemCombo { Valor = r.LeerInt("Valor"), Texto = r.LeerString("Texto") };
        }

        public List<Voluntario> Listar(string texto, string estado)
        {
            return SqlHelper.EjecutarLista("sp_Voluntarios_Listar", Mapear,
                SqlHelper.P("@Texto", texto),
                SqlHelper.P("@Estado", estado));
        }

        public Voluntario Obtener(int id)
        {
            return SqlHelper.EjecutarUno("sp_Voluntarios_Obtener", Mapear, SqlHelper.P("@IDVoluntario", id));
        }

        /// <summary>Ficha completa con rango, roles y estadísticas (para DetailsView).</summary>
        public DataTable ObtenerFicha(int id)
        {
            return SqlHelper.EjecutarDataTable("sp_Voluntarios_Ficha", SqlHelper.P("@IDVoluntario", id));
        }

        public int Insertar(Voluntario v)
        {
            return SqlHelper.EjecutarInsert("sp_Voluntarios_Insertar", Parametros(v, false));
        }

        public void Actualizar(Voluntario v)
        {
            SqlHelper.EjecutarNonQuery("sp_Voluntarios_Actualizar", Parametros(v, true));
        }

        public void BajaLogica(int id)
        {
            SqlHelper.EjecutarNonQuery("sp_Voluntarios_BajaLogica", SqlHelper.P("@IDVoluntario", id));
        }

        public List<ItemCombo> Combo(bool soloActivos)
        {
            return SqlHelper.EjecutarLista("sp_Voluntarios_Combo", MapearCombo, SqlHelper.P("@SoloActivos", soloActivos));
        }

        private static System.Data.SqlClient.SqlParameter[] Parametros(Voluntario v, bool incluirId)
        {
            var lista = new List<System.Data.SqlClient.SqlParameter>
            {
                SqlHelper.P("@Nombre", v.Nombre),
                SqlHelper.P("@Apellido", v.Apellido),
                SqlHelper.P("@DNI", v.DNI),
                SqlHelper.P("@FechaNacimiento", v.FechaNacimiento),
                SqlHelper.P("@Telefono", v.Telefono),
                SqlHelper.P("@Email", v.Email),
                SqlHelper.P("@Direccion", v.Direccion),
                SqlHelper.P("@FechaIngreso", v.FechaIngreso),
                SqlHelper.P("@Estado", v.Estado)
            };
            if (incluirId) lista.Insert(0, SqlHelper.P("@IDVoluntario", v.IDVoluntario));
            return lista.ToArray();
        }
    }
}
