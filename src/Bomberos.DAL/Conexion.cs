using System.Configuration;
using System.Data.SqlClient;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Punto único de acceso a la cadena de conexión.
    /// La cadena se lee del archivo Web.config (sección connectionStrings, nombre "DBBomberos").
    /// </summary>
    public static class Conexion
    {
        public const string NombreCadena = "DBBomberos";

        public static string CadenaConexion
        {
            get
            {
                ConnectionStringSettings cs = ConfigurationManager.ConnectionStrings[NombreCadena];
                if (cs == null || string.IsNullOrWhiteSpace(cs.ConnectionString))
                    throw new DatosException("No se encontró la cadena de conexión '" + NombreCadena + "' en el archivo de configuración.");
                return cs.ConnectionString;
            }
        }

        /// <summary>
        /// Crea una nueva conexión (cerrada). Debe utilizarse dentro de un bloque using.
        /// </summary>
        public static SqlConnection CrearConexion()
        {
            return new SqlConnection(CadenaConexion);
        }
    }
}
