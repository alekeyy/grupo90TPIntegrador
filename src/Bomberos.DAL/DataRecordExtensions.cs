using System;
using System.Data;

namespace Bomberos.DAL
{
    /// <summary>
    /// Métodos de extensión para leer columnas por nombre desde un IDataRecord
    /// manejando correctamente los valores NULL.
    /// </summary>
    internal static class DataRecordExtensions
    {
        public static int LeerInt(this IDataRecord r, string columna)
        {
            object v = r[columna];
            return v == DBNull.Value ? 0 : Convert.ToInt32(v);
        }

        public static string LeerString(this IDataRecord r, string columna)
        {
            object v = r[columna];
            return v == DBNull.Value ? null : Convert.ToString(v);
        }

        public static DateTime LeerFecha(this IDataRecord r, string columna)
        {
            object v = r[columna];
            return v == DBNull.Value ? DateTime.MinValue : Convert.ToDateTime(v);
        }

        public static DateTime? LeerFechaNull(this IDataRecord r, string columna)
        {
            object v = r[columna];
            return v == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(v);
        }

        public static decimal LeerDecimal(this IDataRecord r, string columna)
        {
            object v = r[columna];
            return v == DBNull.Value ? 0m : Convert.ToDecimal(v);
        }

        public static TimeSpan LeerHora(this IDataRecord r, string columna)
        {
            object v = r[columna];
            if (v == DBNull.Value) return TimeSpan.Zero;
            if (v is TimeSpan) return (TimeSpan)v;
            return TimeSpan.Parse(Convert.ToString(v));
        }

        public static bool LeerBool(this IDataRecord r, string columna)
        {
            object v = r[columna];
            return v != DBNull.Value && Convert.ToBoolean(v);
        }
    }
}
