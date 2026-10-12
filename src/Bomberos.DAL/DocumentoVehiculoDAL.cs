using System.Collections.Generic;
using System.Data;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Acceso a datos de la tabla DocumentacionVehiculo.
    /// </summary>
    public class DocumentoVehiculoDAL
    {
        private static DocumentoVehiculo Mapear(IDataRecord r)
        {
            return new DocumentoVehiculo
            {
                IDDocumento = r.LeerInt("IDDocumento"),
                IDVehiculo = r.LeerInt("IDVehiculo"),
                TipoDocumento = r.LeerString("TipoDocumento"),
                FechaEmision = r.LeerFecha("FechaEmision"),
                FechaVencimiento = r.LeerFecha("FechaVencimiento"),
                Estado = r.LeerString("Estado"),
                VehiculoNombre = r.LeerString("VehiculoNombre"),
                Patente = r.LeerString("Patente"),
                DiasParaVencer = r.LeerInt("DiasParaVencer"),
                Situacion = r.LeerString("Situacion")
            };
        }

        /// <summary>Actualiza la columna Estado (Vigente/Vencido) según la fecha actual.</summary>
        public void ActualizarEstados()
        {
            SqlHelper.EjecutarNonQuery("sp_DocumentacionVehiculo_ActualizarEstados");
        }

        /// <param name="situacion">Vencido | Proximo | Vigente | null (todos)</param>
        public List<DocumentoVehiculo> Listar(int? idVehiculo, string situacion, int diasAviso)
        {
            return SqlHelper.EjecutarLista("sp_DocumentacionVehiculo_Listar", Mapear,
                SqlHelper.P("@IDVehiculo", idVehiculo),
                SqlHelper.P("@Situacion", situacion),
                SqlHelper.P("@DiasAviso", diasAviso));
        }

        public DocumentoVehiculo Obtener(int id)
        {
            return SqlHelper.EjecutarUno("sp_DocumentacionVehiculo_Obtener", Mapear, SqlHelper.P("@IDDocumento", id));
        }

        public int Insertar(DocumentoVehiculo d)
        {
            return SqlHelper.EjecutarInsert("sp_DocumentacionVehiculo_Insertar",
                SqlHelper.P("@IDVehiculo", d.IDVehiculo),
                SqlHelper.P("@TipoDocumento", d.TipoDocumento),
                SqlHelper.P("@FechaEmision", d.FechaEmision),
                SqlHelper.P("@FechaVencimiento", d.FechaVencimiento));
        }

        public void Actualizar(DocumentoVehiculo d)
        {
            SqlHelper.EjecutarNonQuery("sp_DocumentacionVehiculo_Actualizar",
                SqlHelper.P("@IDDocumento", d.IDDocumento),
                SqlHelper.P("@IDVehiculo", d.IDVehiculo),
                SqlHelper.P("@TipoDocumento", d.TipoDocumento),
                SqlHelper.P("@FechaEmision", d.FechaEmision),
                SqlHelper.P("@FechaVencimiento", d.FechaVencimiento));
        }

        public void Eliminar(int id)
        {
            SqlHelper.EjecutarNonQuery("sp_DocumentacionVehiculo_Eliminar", SqlHelper.P("@IDDocumento", id));
        }
    }
}
