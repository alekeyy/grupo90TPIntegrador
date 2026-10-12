using System;
using System.Collections.Generic;
using System.Data;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Acceso a datos de la tabla Entrenamientos.
    /// </summary>
    public class EntrenamientoDAL
    {
        private static Entrenamiento Mapear(IDataRecord r)
        {
            return new Entrenamiento
            {
                IDEntrenamiento = r.LeerInt("IDEntrenamiento"),
                IDTipoEntrenamiento = r.LeerInt("IDTipoEntrenamiento"),
                IDVoluntario = r.LeerInt("IDVoluntario"),
                Fecha = r.LeerFecha("Fecha"),
                Observaciones = r.LeerString("Observaciones"),
                TipoNombre = r.LeerString("TipoNombre"),
                VoluntarioNombre = r.LeerString("VoluntarioNombre")
            };
        }

        public List<Entrenamiento> Listar(int? idVoluntario, int? idTipo, DateTime? desde, DateTime? hasta)
        {
            return SqlHelper.EjecutarLista("sp_Entrenamientos_Listar", Mapear,
                SqlHelper.P("@IDVoluntario", idVoluntario),
                SqlHelper.P("@IDTipoEntrenamiento", idTipo),
                SqlHelper.P("@Desde", desde),
                SqlHelper.P("@Hasta", hasta));
        }

        public Entrenamiento Obtener(int id)
        {
            return SqlHelper.EjecutarUno("sp_Entrenamientos_Obtener", Mapear, SqlHelper.P("@IDEntrenamiento", id));
        }

        public int Insertar(Entrenamiento e)
        {
            return SqlHelper.EjecutarInsert("sp_Entrenamientos_Insertar",
                SqlHelper.P("@IDTipoEntrenamiento", e.IDTipoEntrenamiento),
                SqlHelper.P("@IDVoluntario", e.IDVoluntario),
                SqlHelper.P("@Fecha", e.Fecha),
                SqlHelper.P("@Observaciones", e.Observaciones));
        }

        public void Actualizar(Entrenamiento e)
        {
            SqlHelper.EjecutarNonQuery("sp_Entrenamientos_Actualizar",
                SqlHelper.P("@IDEntrenamiento", e.IDEntrenamiento),
                SqlHelper.P("@IDTipoEntrenamiento", e.IDTipoEntrenamiento),
                SqlHelper.P("@IDVoluntario", e.IDVoluntario),
                SqlHelper.P("@Fecha", e.Fecha),
                SqlHelper.P("@Observaciones", e.Observaciones));
        }

        public void Eliminar(int id)
        {
            SqlHelper.EjecutarNonQuery("sp_Entrenamientos_Eliminar", SqlHelper.P("@IDEntrenamiento", id));
        }
    }
}
