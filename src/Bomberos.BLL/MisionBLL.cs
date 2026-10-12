using System.Collections.Generic;
using Bomberos.DAL;
using Bomberos.Entities;

namespace Bomberos.BLL
{
    /// <summary>
    /// Reglas de negocio de Misiones y de la asignación de voluntarios, vehículos y equipamiento.
    /// Estados posibles: En curso, Finalizada, Cancelada.
    /// </summary>
    public class MisionBLL
    {
        private readonly MisionDAL _dal = new MisionDAL();
        private readonly IncidenteDAL _incidenteDal = new IncidenteDAL();

        public List<Mision> Listar(string estado, int? idIncidente, int? idTipoMision, string texto)
        {
            return _dal.Listar(Texto.Normalizar(estado), idIncidente, idTipoMision, Texto.Normalizar(texto));
        }

        public Mision Obtener(int id)
        {
            return _dal.Obtener(id);
        }

        public int Guardar(Mision m)
        {
            m.Nombre = Texto.Normalizar(m.Nombre);
            m.Estado = Texto.Normalizar(m.Estado);

            Validador v = new Validador()
                .Seleccionado(m.IDIncidente, "un incidente")
                .Seleccionado(m.IDTipoMision, "un tipo de misión")
                .Requerido(m.Nombre, "Nombre").LongitudMaxima(m.Nombre, 100, "Nombre")
                .FechaValida(m.FechaInicio, "Fecha de inicio")
                .EnLista(m.Estado, Constantes.EstadosMision, "Estado")
                .Regla(!m.FechaFin.HasValue || m.FechaFin >= m.FechaInicio, "La fecha de fin no puede ser anterior a la fecha de inicio.")
                .Regla(m.Estado != Constantes.MisionFinalizada || m.FechaFin.HasValue, "Una misión finalizada debe tener fecha de fin.")
                .Regla(m.Estado != Constantes.MisionEnCurso || !m.FechaFin.HasValue, "Una misión en curso no puede tener fecha de fin.");

            if (m.IDIncidente > 0)
            {
                Incidente inc = _incidenteDal.Obtener(m.IDIncidente);
                v.Regla(inc != null, "El incidente seleccionado no existe.");
                if (inc != null)
                    v.Regla(m.FechaInicio >= inc.FechaHora, "La misión no puede iniciar antes de la fecha y hora del incidente ("
                                                            + inc.FechaHora.ToString("dd/MM/yyyy HH:mm") + ").");
            }
            v.Lanzar();

            if (m.IDMision == 0)
                return _dal.Insertar(m);

            _dal.Actualizar(m);
            return m.IDMision;
        }

        /// <summary>Elimina la misión y todas sus asignaciones.</summary>
        public void Eliminar(int id)
        {
            _dal.Eliminar(id);
        }

        // ------------------------------------------------------------------
        // Asignaciones
        // ------------------------------------------------------------------
        public List<RecursoAsignado> ListarRecursos(TipoRecurso tipo, int idMision)
        {
            return _dal.ListarRecursos(tipo, idMision);
        }

        public void AgregarRecurso(TipoRecurso tipo, int idMision, int idRecurso)
        {
            Mision m = _dal.Obtener(idMision);
            new Validador()
                .Regla(m != null, "La misión no existe.")
                .Seleccionado(idRecurso, tipo == TipoRecurso.Voluntario ? "un voluntario"
                                       : tipo == TipoRecurso.Vehiculo ? "un vehículo" : "un equipo")
                .Lanzar();
            if (m.Estado == Constantes.MisionCancelada)
                throw new ValidacionException("No se pueden asignar recursos a una misión cancelada.");

            _dal.AgregarRecurso(tipo, idMision, idRecurso);
        }

        public void QuitarRecurso(TipoRecurso tipo, int idMision, int idRecurso)
        {
            _dal.QuitarRecurso(tipo, idMision, idRecurso);
        }
    }
}
