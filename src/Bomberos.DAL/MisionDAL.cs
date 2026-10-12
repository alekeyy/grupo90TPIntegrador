using System.Collections.Generic;
using System.Data;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Acceso a datos de Misiones y de sus asignaciones de recursos
    /// (MisionVoluntario, MisionVehiculo, MisionEquipamiento).
    /// </summary>
    public class MisionDAL
    {
        private static Mision Mapear(IDataRecord r)
        {
            return new Mision
            {
                IDMision = r.LeerInt("IDMision"),
                IDIncidente = r.LeerInt("IDIncidente"),
                IDTipoMision = r.LeerInt("IDTipoMision"),
                Nombre = r.LeerString("Nombre"),
                FechaInicio = r.LeerFecha("FechaInicio"),
                FechaFin = r.LeerFechaNull("FechaFin"),
                Estado = r.LeerString("Estado"),
                IncidenteDireccion = r.LeerString("IncidenteDireccion"),
                IncidenteFechaHora = r.LeerFecha("IncidenteFechaHora"),
                IncidenteSeveridad = r.LeerString("IncidenteSeveridad"),
                TipoMisionNombre = r.LeerString("TipoMisionNombre"),
                CantidadVoluntarios = r.LeerInt("CantidadVoluntarios"),
                CantidadVehiculos = r.LeerInt("CantidadVehiculos"),
                CantidadEquipamiento = r.LeerInt("CantidadEquipamiento")
            };
        }

        private static RecursoAsignado MapearRecurso(IDataRecord r)
        {
            return new RecursoAsignado
            {
                ID = r.LeerInt("ID"),
                Descripcion = r.LeerString("Descripcion"),
                Detalle = r.LeerString("Detalle"),
                Estado = r.LeerString("Estado")
            };
        }

        public List<Mision> Listar(string estado, int? idIncidente, int? idTipoMision, string texto)
        {
            return SqlHelper.EjecutarLista("sp_Misiones_Listar", Mapear,
                SqlHelper.P("@Estado", estado),
                SqlHelper.P("@IDIncidente", idIncidente),
                SqlHelper.P("@IDTipoMision", idTipoMision),
                SqlHelper.P("@Texto", texto));
        }

        public Mision Obtener(int id)
        {
            return SqlHelper.EjecutarUno("sp_Misiones_Obtener", Mapear, SqlHelper.P("@IDMision", id));
        }

        public int Insertar(Mision m)
        {
            return SqlHelper.EjecutarInsert("sp_Misiones_Insertar",
                SqlHelper.P("@IDIncidente", m.IDIncidente),
                SqlHelper.P("@IDTipoMision", m.IDTipoMision),
                SqlHelper.P("@Nombre", m.Nombre),
                SqlHelper.P("@FechaInicio", m.FechaInicio),
                SqlHelper.P("@FechaFin", m.FechaFin),
                SqlHelper.P("@Estado", m.Estado));
        }

        public void Actualizar(Mision m)
        {
            SqlHelper.EjecutarNonQuery("sp_Misiones_Actualizar",
                SqlHelper.P("@IDMision", m.IDMision),
                SqlHelper.P("@IDIncidente", m.IDIncidente),
                SqlHelper.P("@IDTipoMision", m.IDTipoMision),
                SqlHelper.P("@Nombre", m.Nombre),
                SqlHelper.P("@FechaInicio", m.FechaInicio),
                SqlHelper.P("@FechaFin", m.FechaFin),
                SqlHelper.P("@Estado", m.Estado));
        }

        public void Eliminar(int id)
        {
            SqlHelper.EjecutarNonQuery("sp_Misiones_Eliminar", SqlHelper.P("@IDMision", id));
        }

        // ------------------------------------------------------------------
        // Asignación de recursos
        // ------------------------------------------------------------------

        /// <summary>Devuelve la tabla intermedia y el nombre del parámetro de cada tipo de recurso.</summary>
        private static void Resolver(TipoRecurso tipo, out string tabla, out string parametro)
        {
            switch (tipo)
            {
                case TipoRecurso.Vehiculo:
                    tabla = "MisionVehiculo"; parametro = "@IDVehiculo"; break;
                case TipoRecurso.Equipamiento:
                    tabla = "MisionEquipamiento"; parametro = "@IDEquipamiento"; break;
                default:
                    tabla = "MisionVoluntario"; parametro = "@IDVoluntario"; break;
            }
        }

        public List<RecursoAsignado> ListarRecursos(TipoRecurso tipo, int idMision)
        {
            string tabla, parametro;
            Resolver(tipo, out tabla, out parametro);
            return SqlHelper.EjecutarLista("sp_" + tabla + "_Listar", MapearRecurso, SqlHelper.P("@IDMision", idMision));
        }

        public void AgregarRecurso(TipoRecurso tipo, int idMision, int idRecurso)
        {
            string tabla, parametro;
            Resolver(tipo, out tabla, out parametro);
            SqlHelper.EjecutarNonQuery("sp_" + tabla + "_Agregar",
                SqlHelper.P("@IDMision", idMision),
                SqlHelper.P(parametro, idRecurso));
        }

        public void QuitarRecurso(TipoRecurso tipo, int idMision, int idRecurso)
        {
            string tabla, parametro;
            Resolver(tipo, out tabla, out parametro);
            SqlHelper.EjecutarNonQuery("sp_" + tabla + "_Quitar",
                SqlHelper.P("@IDMision", idMision),
                SqlHelper.P(parametro, idRecurso));
        }
    }
}
