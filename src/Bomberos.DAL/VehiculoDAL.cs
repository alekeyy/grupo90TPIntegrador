using System.Collections.Generic;
using System.Data;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Acceso a datos de la tabla Vehiculos.
    /// </summary>
    public class VehiculoDAL
    {
        private static Vehiculo Mapear(IDataRecord r)
        {
            return new Vehiculo
            {
                IDVehiculo = r.LeerInt("IDVehiculo"),
                Nombre = r.LeerString("Nombre"),
                Anio = r.LeerInt("Anio"),
                Patente = r.LeerString("Patente"),
                Estado = r.LeerString("Estado"),
                IDTipoVehiculo = r.LeerInt("IDTipoVehiculo"),
                TipoNombre = r.LeerString("TipoNombre"),
                DocumentosVencidos = r.LeerInt("DocumentosVencidos")
            };
        }

        public List<Vehiculo> Listar(string patente, string estado, int? idTipoVehiculo)
        {
            return SqlHelper.EjecutarLista("sp_Vehiculos_Listar", Mapear,
                SqlHelper.P("@Patente", patente),
                SqlHelper.P("@Estado", estado),
                SqlHelper.P("@IDTipoVehiculo", idTipoVehiculo));
        }

        public Vehiculo Obtener(int id)
        {
            return SqlHelper.EjecutarUno("sp_Vehiculos_Obtener", Mapear, SqlHelper.P("@IDVehiculo", id));
        }

        public int Insertar(Vehiculo v)
        {
            return SqlHelper.EjecutarInsert("sp_Vehiculos_Insertar",
                SqlHelper.P("@Nombre", v.Nombre),
                SqlHelper.P("@Anio", v.Anio),
                SqlHelper.P("@Patente", v.Patente),
                SqlHelper.P("@Estado", v.Estado),
                SqlHelper.P("@IDTipoVehiculo", v.IDTipoVehiculo));
        }

        public void Actualizar(Vehiculo v)
        {
            SqlHelper.EjecutarNonQuery("sp_Vehiculos_Actualizar",
                SqlHelper.P("@IDVehiculo", v.IDVehiculo),
                SqlHelper.P("@Nombre", v.Nombre),
                SqlHelper.P("@Anio", v.Anio),
                SqlHelper.P("@Patente", v.Patente),
                SqlHelper.P("@Estado", v.Estado),
                SqlHelper.P("@IDTipoVehiculo", v.IDTipoVehiculo));
        }

        public void Eliminar(int id)
        {
            SqlHelper.EjecutarNonQuery("sp_Vehiculos_Eliminar", SqlHelper.P("@IDVehiculo", id));
        }

        public List<ItemCombo> Combo(bool soloOperativos)
        {
            return SqlHelper.EjecutarLista("sp_Vehiculos_Combo", VoluntarioDAL.MapearCombo,
                SqlHelper.P("@SoloOperativos", soloOperativos));
        }
    }
}
