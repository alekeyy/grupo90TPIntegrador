using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Clase de ayuda reutilizable para ejecutar Stored Procedures con ADO.NET.
    /// Centraliza la apertura/cierre de conexiones, la creación de comandos y la
    /// traducción de errores de SQL Server a mensajes comprensibles (DatosException).
    /// </summary>
    public static class SqlHelper
    {
        private const int TiempoEsperaSegundos = 30;

        /// <summary>
        /// Crea un parámetro convirtiendo null en DBNull.Value.
        /// </summary>
        public static SqlParameter P(string nombre, object valor)
        {
            return new SqlParameter(nombre, valor ?? DBNull.Value);
        }

        /// <summary>
        /// Ejecuta un SP y devuelve el resultado como DataTable (usado en reportes).
        /// </summary>
        public static DataTable EjecutarDataTable(string storedProcedure, params SqlParameter[] parametros)
        {
            try
            {
                using (SqlConnection cn = Conexion.CrearConexion())
                using (SqlCommand cmd = CrearComando(cn, storedProcedure, parametros))
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    return dt;
                }
            }
            catch (SqlException ex)
            {
                throw TraducirError(ex);
            }
        }

        /// <summary>
        /// Ejecuta un SP y mapea cada fila a un objeto mediante la función indicada.
        /// </summary>
        public static List<T> EjecutarLista<T>(string storedProcedure, Func<IDataRecord, T> mapear, params SqlParameter[] parametros)
        {
            List<T> lista = new List<T>();
            try
            {
                using (SqlConnection cn = Conexion.CrearConexion())
                using (SqlCommand cmd = CrearComando(cn, storedProcedure, parametros))
                {
                    cn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                            lista.Add(mapear(dr));
                    }
                }
                return lista;
            }
            catch (SqlException ex)
            {
                throw TraducirError(ex);
            }
        }

        /// <summary>
        /// Ejecuta un SP que devuelve a lo sumo una fila. Devuelve default(T) si no hay filas.
        /// </summary>
        public static T EjecutarUno<T>(string storedProcedure, Func<IDataRecord, T> mapear, params SqlParameter[] parametros)
        {
            List<T> lista = EjecutarLista(storedProcedure, mapear, parametros);
            return lista.Count > 0 ? lista[0] : default(T);
        }

        /// <summary>
        /// Ejecuta un SP que no devuelve filas (UPDATE / DELETE).
        /// </summary>
        public static int EjecutarNonQuery(string storedProcedure, params SqlParameter[] parametros)
        {
            try
            {
                using (SqlConnection cn = Conexion.CrearConexion())
                using (SqlCommand cmd = CrearComando(cn, storedProcedure, parametros))
                {
                    cn.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException ex)
            {
                throw TraducirError(ex);
            }
        }

        /// <summary>
        /// Ejecuta un SP y devuelve la primera columna de la primera fila.
        /// </summary>
        public static object EjecutarEscalar(string storedProcedure, params SqlParameter[] parametros)
        {
            try
            {
                using (SqlConnection cn = Conexion.CrearConexion())
                using (SqlCommand cmd = CrearComando(cn, storedProcedure, parametros))
                {
                    cn.Open();
                    return cmd.ExecuteScalar();
                }
            }
            catch (SqlException ex)
            {
                throw TraducirError(ex);
            }
        }

        /// <summary>
        /// Ejecuta un SP de alta que devuelve el ID generado (SELECT ... AS ID).
        /// </summary>
        public static int EjecutarInsert(string storedProcedure, params SqlParameter[] parametros)
        {
            object resultado = EjecutarEscalar(storedProcedure, parametros);
            return resultado == null || resultado == DBNull.Value ? 0 : Convert.ToInt32(resultado);
        }

        private static SqlCommand CrearComando(SqlConnection cn, string storedProcedure, SqlParameter[] parametros)
        {
            SqlCommand cmd = new SqlCommand(storedProcedure, cn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandTimeout = TiempoEsperaSegundos;
            if (parametros != null)
            {
                foreach (SqlParameter p in parametros)
                {
                    if (p != null) cmd.Parameters.Add(p);
                }
            }
            return cmd;
        }

        /// <summary>
        /// Convierte una SqlException en una DatosException con un mensaje claro para el usuario.
        /// </summary>
        public static DatosException TraducirError(SqlException ex)
        {
            string mensaje;
            switch (ex.Number)
            {
                case 547:   // Violación de clave foránea / CHECK
                    mensaje = "La operación no se puede realizar porque el registro está relacionado con otros datos o no cumple una restricción de la base de datos.";
                    break;
                case 2601:  // Índice único
                case 2627:  // Clave primaria / UNIQUE
                    mensaje = "Ya existe un registro con los mismos datos (valor duplicado).";
                    break;
                case 8152:
                case 2628:  // Texto demasiado largo
                    mensaje = "Uno de los textos ingresados supera la longitud máxima permitida.";
                    break;
                case -2:    // Timeout
                    mensaje = "La base de datos tardó demasiado en responder. Intente nuevamente.";
                    break;
                case -1:
                case 2:
                case 26:    // No se encontró la instancia
                case 40:    // No se pudo abrir la conexión
                case 53:
                case 4060:  // No se puede abrir la base
                case 18456: // Login fallido
                    mensaje = "No se pudo conectar con la base de datos. Verifique que SQL Server esté en ejecución y la cadena de conexión en Web.config.";
                    break;
                case 2812:  // SP inexistente
                    mensaje = "No se encontró un procedimiento almacenado en la base de datos. Ejecute el script '3. Stored Procedures.sql'.";
                    break;
                default:
                    // Errores de negocio lanzados con THROW 50000+ desde los SP: el mensaje ya es para el usuario.
                    mensaje = ex.Number >= 50000 ? ex.Message : "Error de base de datos: " + ex.Message;
                    break;
            }
            return new DatosException(mensaje, ex.Number, ex);
        }
    }
}
