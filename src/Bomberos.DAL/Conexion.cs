using System.Configuration;
using System.Data.SqlClient;

namespace Bomberos.DAL
{
    /// <summary>
    /// Punto único de acceso a la base de datos.
    /// La cadena de conexión se lee del Web.config (connectionStrings, nombre "DBBomberos").
    /// </summary>
    public static class Conexion
    {
        public const string NombreCadena = "DBBomberos";

        public static string CadenaConexion
        {
            get { return ConfigurationManager.ConnectionStrings[NombreCadena].ConnectionString; }
        }

        /// <summary>
        /// Crea una nueva conexión (cerrada). Usar siempre dentro de un bloque using.
        /// </summary>
        public static SqlConnection CrearConexion()
        {
            return new SqlConnection(CadenaConexion);
        }
    }
}
