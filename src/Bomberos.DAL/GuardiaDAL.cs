using System;
using System.Collections.Generic;
using System.Data;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Acceso a datos de la tabla Guardias.
    /// </summary>
    public class GuardiaDAL
    {
        private static Guardia Mapear(IDataRecord r)
        {
            return new Guardia
            {
                IDGuardia = r.LeerInt("IDGuardia"),
                IDVoluntario = r.LeerInt("IDVoluntario"),
                Fecha = r.LeerFecha("Fecha"),
                HoraInicio = r.LeerHora("HoraInicio"),
                HoraFin = r.LeerHora("HoraFin"),
                VoluntarioNombre = r.LeerString("VoluntarioNombre"),
                EnCurso = r.LeerBool("EnCurso")
            };
        }

        public List<Guardia> Listar(int? idVoluntario, DateTime? desde, DateTime? hasta)
        {
            return SqlHelper.EjecutarLista("sp_Guardias_Listar", Mapear,
                SqlHelper.P("@IDVoluntario", idVoluntario),
                SqlHelper.P("@Desde", desde),
                SqlHelper.P("@Hasta", hasta));
        }

        public Guardia Obtener(int id)
        {
            return SqlHelper.EjecutarUno("sp_Guardias_Obtener", Mapear, SqlHelper.P("@IDGuardia", id));
        }

        public int Insertar(Guardia g)
        {
            return SqlHelper.EjecutarInsert("sp_Guardias_Insertar",
                SqlHelper.P("@IDVoluntario", g.IDVoluntario),
                SqlHelper.P("@Fecha", g.Fecha),
                SqlHelper.P("@HoraInicio", g.HoraInicio),
                SqlHelper.P("@HoraFin", g.HoraFin));
        }

        public void Actualizar(Guardia g)
        {
            SqlHelper.EjecutarNonQuery("sp_Guardias_Actualizar",
                SqlHelper.P("@IDGuardia", g.IDGuardia),
                SqlHelper.P("@IDVoluntario", g.IDVoluntario),
                SqlHelper.P("@Fecha", g.Fecha),
                SqlHelper.P("@HoraInicio", g.HoraInicio),
                SqlHelper.P("@HoraFin", g.HoraFin));
        }

        public void Eliminar(int id)
        {
            SqlHelper.EjecutarNonQuery("sp_Guardias_Eliminar", SqlHelper.P("@IDGuardia", id));
        }
    }
}
