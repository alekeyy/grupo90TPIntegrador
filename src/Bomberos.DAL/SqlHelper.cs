using System;
using System.Data;
using System.Data.SqlClient;

namespace Bomberos.DAL
{
    /// <summary>
    /// Métodos reutilizables para ejecutar comandos con ADO.NET.
    /// Abren y cierran la conexión automáticamente.
    /// </summary>
    public static class SqlHelper
    {
        /// <summary>Crea un parámetro convirtiendo null en DBNull.Value.</summary>
        public static SqlParameter Parametro(string nombre, object valor)
        {
            return new SqlParameter(nombre, valor ?? DBNull.Value);
        }

        /// <summary>Ejecuta una consulta y devuelve el resultado en un DataTable.</summary>
        public static DataTable EjecutarDataTable(string comando, CommandType tipo, params SqlParameter[] parametros)
        {
            using (SqlConnection cn = Conexion.CrearConexion())
            using (SqlCommand cmd = CrearComando(cn, comando, tipo, parametros))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }

        /// <summary>Ejecuta un comando que no devuelve filas (INSERT, UPDATE, DELETE). Devuelve las filas afectadas.</summary>
        public static int EjecutarNonQuery(string comando, CommandType tipo, params SqlParameter[] parametros)
        {
            using (SqlConnection cn = Conexion.CrearConexion())
            using (SqlCommand cmd = CrearComando(cn, comando, tipo, parametros))
            {
                cn.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        /// <summary>Ejecuta un comando y devuelve la primera columna de la primera fila.</summary>
        public static object EjecutarEscalar(string comando, CommandType tipo, params SqlParameter[] parametros)
        {
            using (SqlConnection cn = Conexion.CrearConexion())
            using (SqlCommand cmd = CrearComando(cn, comando, tipo, parametros))
            {
                cn.Open();
                return cmd.ExecuteScalar();
            }
        }

        private static SqlCommand CrearComando(SqlConnection cn, string comando, CommandType tipo, SqlParameter[] parametros)
        {
            SqlCommand cmd = new SqlCommand(comando, cn);
            cmd.CommandType = tipo;
            if (parametros != null)
                cmd.Parameters.AddRange(parametros);
            return cmd;
        }
    }
}
